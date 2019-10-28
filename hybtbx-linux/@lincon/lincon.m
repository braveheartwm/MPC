function L=lincon(sys,type,cost,interval,limits,qpsolver,yzerocon)
%LINCON Constructor for @LINCON class -- Constrained linear quadratic controller 
%       for linear systems
%
% L=LINCON(SYS,TYPE,COST,INTERVAL,LIMITS) build a regulator
% (or a controller for reference tracking) based on a finite time linear 
% quadratic constrained optimal control formulation.
%
% 1) Regulator:
%
% min x'(N)Px(N) + sum_{k=0}^{N-1} x'(k)Qx(k) + u'(k)Ru(k) + rho*eps^2
%
% s.t. ymin - eps <= y(k) <=ymax + eps, k=1,...,Ncy
%            umin <= u(k) <=umax,       k=0,...,Ncu
%             u(k) = K*x(k),            k>=Nu
%
%      x(t+1) = A x(t)+ B u(t)
%        y(t) = C x(t)+ D u(t)
%
% 2) Controller for reference tracking:
%
% min sum_{k=0}^{N-1} [y(k)-r]'S[y(k)-r] + du'(k) T du(k) + rho*eps^2
%
% s.t. ymin - eps <= y(k)  <=ymax + eps, k=1,...,Ncy
%            umin <= u(k)  <=umax,       k=0,...,Ncu
%           dumin <= du(k) <=dumax,      k=0,...,Ncu
%            du(k) = 0,                  k>=Nu
%
%      x(t+1) = Ax(t) + B [u(t-1)+du(t)]   du(t) = u(t)-u(t-1) = input increment
%        y(t) = Cx(t) + D [u(t-1)+du(t)]
%
% Input arguments:
%
% SYS is the discrete-time linear time-invariant model (A,B,C,D,TS)
%
% TYPE defines the type of controller. Valid types are
%     'reg'   = regulator
%     'track' = controller for reference tracking
%
% COST is a structure of weights with fields:
%    .Q = weight Q on states             [ x'(k)Qx(k) ]           (regulator only)
%    .R = weight R on inputs             [ u'(k)Ru(k) ]           (regulator only)
%    .P = weight P on final state        [ x'(N)Px(N) ]           (regulator only)
%    .S = weight S on outputs            [ (y(k)-r)'S(y(k)-r) ]   (tracking only)
%    .T = weight T on input increments   [ du'(k) T du(k) ]       (tracking only)
%  .rho = weight on slack var     [ rho*eps^2  ]                  (regulator and tracking)
%         rho=Inf means hard output constraints
%    .K = feedback gain (default: K=0)   [ u(k)=K*x(k) for k>=Nu] (only regulator)
%
%  Only for regulators: 
%  If COST.P='lqr' then P is chosen as the solution of the LQR problem
%  with weights Q,R, and K is chosen as the corresponding LQR gain.
%  If COST.P='lyap' then P is chosen as the solution of the Lyapunov equation
%  A'*P*A - P + Q = 0, and K=0 (default).
%
% INTERVAL is a structure of number of input and output optimal control steps 
%        .N = optimal control interval over which the cost function is summed
%       .Nu = number of free optimal control moves u(0),...,u(Nu-1)
%      .Ncy = output constraints are checked up to time k=Ncy
%      .Ncu = input constraints are checked up to time k=Ncu
%
% LIMITS is a structure of constraints with fields:
%    .umin = lower bounds on inputs            [ u(k)>=umin ]
%    .umax = upper bounds on inputs            [ u(k)<=umax ]
%    .ymin = lower bounds on outputs           [ y(k)>=ymin ]
%    .ymax = upper bounds on outputs           [ y(k)<=ymax ]
%   .dumin = lower bounds on input increments  [ du(k)>=dumin ] (only tracking)
%   .dumax = upper bounds on input increments  [ du(k)<=dumax ] (only tracking)
%
% L=LINCON(SYS,TYPE,COST,INTERVAL,LIMITS,QPSOLVER) also specifies the QP
% used for evaluating the control law. Valid options are:
%       'qpact'    active set method
%       'quadprog' QUADPROG from Optimization Toolbox
%       'qp'       QP from Optimization Toolbox
%       'nag'      QP from NAG Foundation Toolbox
%       'cplex'    QP from Ilog Cplex
%
% L=LINCON(SYS,TYPE,COST,INTERVAL,LIMITS,QPSOLVER,YZEROCON) enforce output
% constraints also at prediction time k=0 if YZEROCON=1 (default:
% YZEROCON=0). If YEZEROCON is a 0/1 vector of the same dimension as the output
% vector, then only those outputs where YZEROCON(i)=1 are constrained at
% time k=0.
%
% -------------------------
% Time-varying formulation: Use the same syntax as above, with input arguments as follow: 
%
% SYS = cell array of linear models, SYS{i}=model used to predict at step t+i-1
% COST = cell array of structures of weights: COST{i}.Q, COST{i}.R, etc.
%        Only COST{1}.rho is used for penalty soft constraint penalty, COST{i}.rho 
%        is ignored for i>1.
% LIMITS = cell arrays of structures of upper and lower bounds: LIMITS{i}.umin, etc.
%          The constraints LIMITS{i} refer to time index t+i, for both
%          inputs and outputs.


% (C) 2003-2009 by A. Bemporad

L=struct('Q',[],'C',[],'G',[],'W',[],'S',[],'model',[],'nx',[],'nu',[],'ny',[],...
    'type',[],'ts',[],'isconstr',[],'soft',[],...
    'nvar',[],'nq',[],'npar',[],'QPsolver',[],'I1',[],'Qinv',[],...
    'Observer',[]);

if nargin<1,
    L=class(L,'lincon');    
    return;
end

%-----------------
% Check interval
%-----------------

% Define default interval

movesdef=2;
if nargin<5 | isempty(interval),
    Nudef=movesdef;
    Ndef=Nudef;
    Ncydef=Ndef-1; 
    Ncudef=Nudef-1; 
    interval=struct('N',Ndef,'Nu',Nudef,'Ncu',Ncudef,'Ncy',Ncydef);
end
[Ny,Nu,Ncu,Ncy]=chkinterval(interval,movesdef);
interval=struct('N',Ny,'Nu',Nu,'Ncu',Ncu,'Ncy',Ncy);


%-----------------
% Check model
%-----------------

if ~isa(sys,'cell'),
    [sys,nx,nu,ny]=check_model(sys);
    ts=sys.ts;
    A=sys.A;
    B=sys.B;
else
    [sys{1},nx,nu,ny]=check_model(sys{1});
    ts=sys{1}.ts;
    nsys=length(sys);
    if nsys<Ny,
        warning(sprintf('Time-varying model extended to prediction horizon length N=%d',Ny));
        sys(nsys+1:Ny)=sys(nsys);
    end
    nsys=Ny;
    for i=2:nsys,
        [sys{i},nxi,nui,nyi]=check_model(sys{i});
        if any([nx,nu,ny,sys{i}.ts]~=[nxi,nui,nyi,ts]),
            error('Number of states, inputs, and outputs and sampling time of models should be the same');
        end
    end
    A=sys{Ny}.A; % Use terminal model for possibly computing later terminal cost and gain
    B=sys{Ny}.B;
end

%-----------------
% Check type
%-----------------
if nargin<2 | isempty(type),
    type='reg';
end
if ~ischar(type) | ~ (strcmp(lower(type),'reg') | strcmp(lower(type),'track'))
    error('Controller type must be either ''reg'' or ''track''');
end
type=lower(type);
tracking=strcmp(type,'track');


%-----------------
% Check cost
%-----------------

% Define default weights
Qdef=eye(nx);
Rdef=0.1*eye(nu);
Pdef='lqr';
Kdef=[];
Sdef=eye(ny);
Tdef=0.1*eye(nx);
rhodef=1e4;
if tracking,
    costdef=struct('S',Sdef,'T',Tdef,'rho',rhodef,'Q',[],'R',[],'P',[],'K',[]);
else
    costdef=struct('Q',Qdef,'R',Rdef,'P',Pdef,'rho',rhodef,'K',Kdef,'S',[],'T',[]);
end    
if nargin<3 | isempty(cost),
    cost=rmfield(costdef,'K');
end
if ~isa(cost,'cell'),
    [cost,soft]=chkcost(cost,type,nx,nu,ny,costdef,A,B);
    rho=cost.rho;
    if tracking,
        Q=cost.S;
        R=cost.T;
        P=[];
        K=[];
    else
        Q=cost.Q;
        R=cost.R;
        P=cost.P;
        K=cost.K;
    end
else
    ncost=length(cost);
    if ncost>Ny,
        warning(sprintf('Time-varying weights truncated to prediction horizon length N=%d',Ny));
        cost=cost(1:Ny);
    elseif ncost<Ny,
        warning(sprintf('Time-varying weights extended to prediction horizon length N=%d',Ny));
        cost(ncost+1:Ny)=cost(ncost);
    end
    ncost=Ny;

    for i=1:ncost-1,
        if ~tracking,
            cost{i}.K=zeros(nu,nx);
            cost{i}.P=zeros(nx,nx);
        end
        [cost{i},soft]=chkcost(cost{i},type,nx,nu,ny,costdef);
    end
    if ~isa(sys,'cell'),
        A=sys.A;
        B=sys.B;
    else
        % Possibly compute terminal cost and gain using last model (A,B)
        [cost{ncost},soft]=chkcost(cost{ncost},type,nx,nu,ny,costdef,sys{nsys}.A,sys{nsys}.B);
    end
    rho=cost{1}.rho;
    Q=cell(ncost,1);
    R=cell(ncost,1);
    for i=1:ncost,
        if tracking,
            Q{i}=cost{i}.S;
            R{i}=cost{i}.T;
        else
            Q{i}=cost{i}.Q;
            R{i}=cost{i}.R;
        end
    end
    if tracking,
        P=[];
        K=[];
    else
        P=cost{ncost}.P;
        K=cost{ncost}.K;
    end
end


%-----------------
% Check limits
%-----------------

% Define default limits
limsdef=struct('umin',-Inf*ones(nu,1),'umax',Inf*ones(nu,1),...
    'ymin',-Inf*ones(ny,1),'ymax',Inf*ones(ny,1));
if tracking,
    limsdef.dumin=-Inf*ones(nu,1);
    limsdef.dumax=Inf*ones(nu,1);
end
if nargin<4 | isempty(limits),
    limits=limsdef;
end
if ~isa(limits,'cell'),
    [umin,umax,ymin,ymax,dumin,dumax,isconstr]=chklimits(limits,type,nu,ny,limsdef);
else
    isconstr=0;
    nlims=length(limits);
        Nmax=max(Ncy+1,Ncu+1);
        if nlims>Nmax,
        warning(sprintf('Time-varying limits exceeding prediction step %d ignored',Nmax));
        limits=limits(1:Nmax);
    elseif nlims<Nmax,
        warning(sprintf('Time-varying limits extended up to prediction time %d',Nmax));
        limits(nlims+1:Nmax)=limits(nlims);
    end
    nlims=Nmax;

    umin=zeros(nu,nlims);
    umax=zeros(nu,nlims);
    dumin=zeros(nu,nlims);
    dumax=zeros(nu,nlims);
    ymin=zeros(ny,nlims);
    ymax=zeros(ny,nlims);
    for i=1:nlims,
        [umin(:,i),umax(:,i),ymin(:,i),ymax(:,i),dumin(:,i),dumax(:,i),isconstr_i]=...
            chklimits(limits{i},type,nu,ny,limsdef);
        isconstr=isconstr||isconstr_i;
    end
end

% Convert to hard constraints if the only constraints are on optimization variables
if all(isinf(ymin)) & all(isinf(ymax)) & ...
    ((strcmp(type,'track') & all(isinf(umin)) & all(isinf(umax))) | ...
            strcmp(type,'reg')),
    cost.rho=Inf;
    soft=0;
end


%-----------------
% Check qpsolver
%-----------------

% Define default solver
qpsolverdef='qpact';
if nargin<6 | isempty(qpsolver),
    qpsolver=qpsolverdef;
else
    if ~ischar(qpsolver),
        error('QP solver parameter must be a string');
    end
    qpsolver=lower(qpsolver);
    switch qpsolver
        case {'clp','qpact','qp','quadprog','cplex','nag'}
        otherwise
            error('Unknown QP solver');
    end
end

%-----------------
% Check yzerocon
%-----------------

% Define default 
yzerocondef=0;
if nargin<7 | isempty(yzerocon),
    yzerocon=yzerocondef;
else
    if ~isnumeric(yzerocon),
        error('YZEROCON must be a number or a vector of numbers (0 or 1)');
    end
    yzerocon=yzerocon(:);
    if any(yzerocon~=0 & yzerocon~=1)
        error('YZEROCON must be binary');
    end
    if length(yzerocon)>1 && length(yzerocon)~=ny,
        error(sprintf('YZEROCON must be a binary scalar or a vector of length %d',ny));
    end
end

istimevarying=struct('model',isa(sys,'cell'),'cost',isa(cost,'cell'),'limits',isa(limits,'cell'));

try
    [Q,C,G,W,S,Y,sHm]=buildqp(sys,Q,R,Nu,Ny,Ncu,Ncy,...
           umin,umax,dumin,dumax,ymin,ymax,soft,tracking,K,P,rho,yzerocon,istimevarying);
    [nq,npar]=size(S);
    nvar=nu*Nu;
    I1=kron([1 zeros(1,Nu-1)],eye(nu));
    if soft,
        I1=[I1 zeros(nu,1)];
    end
    L.Q=Q;
    L.C=C;
    L.G=G;
    L.W=W;
    L.S=S;
    L.model=sys;
    internal_struct=struct('Y',Y,'sHm',sHm,'yzerocon',yzerocon,'interval',interval);
    if ~istimevarying.model,
        L.model.Userdata=internal_struct;
    else
        L.model{1}.Userdata=internal_struct;
    end
    L.nx=nx;
    L.nu=nu;
    L.ny=ny;
    L.type=type;
    L.ts=ts;
    L.isconstr=isconstr;
    L.soft=soft;
    L.nvar=nvar;
    L.nq=nq;
    L.npar=npar;
    L.QPsolver=qpsolver;
    L.I1=I1;
    L.Qinv=inv(Q);
    L.Observer='no'; 
catch
    rethrow(lasterror);
end
L=class(L,'lincon');


function [sys,nx,nu,ny]=check_model(sys);
if ~isa(sys,'lti'),
    error('Invalid model');
end
if ~isa(sys,'ss'),
    sys=ss(sys);
end
if ~sys.ts>0,
    error('Model must be discrete time');
end
if hasdelay(sys),
    % Convert delays to states
    sys=delay2z(sys);
end
[nx,nu]=size(sys.b);
ny=size(sys.c,1);
