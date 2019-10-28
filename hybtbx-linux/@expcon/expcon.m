function C=expcon(con,range,options)
%EXPCON Constructor for @EXPCON class -- Explicit controllers (for linear/hybrid systems)
%
% E=EXPCON(C,RANGE,OPTIONS) convert controller C to piecewise affine
% explicit form.
%
% C is a constrained optimal controller for linear systems or hybrid systems
% (an object of class @LINCON or @HYBCON)
%
% RANGE defines the range of the parameters the explicit solution is found
% with respect to (it may be different from the limits over variables imposed
% in the control law). RANGE is a structure with fields:
%    .xmin, xmax = range of states            [ xmin <= x <= xmax ]       (linear and hybrid)
%    .umin, umax = range of inputs            [ umin <= u <= umax ]       (linear w/ tracking)
%    .refymin, refymax = range of output refs [ refymin <= r.y <= refymax]  (linear w/ tracking and hybrid)
%    .refxmin, refxmax = range of state refs  [ refxmin <= r.x <= refxmax ]  (hybrid)
%    .refumin, refumax = range of input refs  [ refumin <= r.u <= refumax ]  (hybrid)
%
% For hybrid controllers, refxmin,refxmax,refumin,refumax,refymin,refymax
% must have dimensions consistent with the number of indices specified in
% C.ref (type "help hybcon" for details)
%
% OPTIONS defines various options for computing the explicit control law:
%    .lpsolver = LP solver (type HELP LPSOL for details)
%    .qpsolver = QP solver (type HELP QPSOL for details)
%    .fixref   = structure with fields 'y','x','u' defining references that are fixed at given
%                values, therefore simplifying the parametric solution [hybrid only]
%    .valueref = structure with fields 'y','x','u' of values at which
%                references are fixed  [hybrid only]
%    .flattol    Tolerance for a polyhedral set to be considered flat
%    .waitbar    display waitbar (only for hybrid)
%    .verbose    = level of verbosity {0,1,2} of mp-PWA solver
%    .mplpverbose = level of verbosity {0,1,2} of mp-LP solver
%    .uniteeps   = tolerance for judging convexity of the union of polyhedra
%    .join       = flag for reducing the complexity by joining regions
%                  whose union is a convex set.
%    .reltol     = tolerance used for several polyhedral operations
%    .sequence   = flag for keeping the entire optimal control sequence
%                  as an explicit function of the parameters also in the
%                  linear case. Flag ignored in the hybrid case: sequence
%                  always stored with quadratic costs, never stored with inf-norms.
%
% Example: to fix the reference signal for x(1),x(2) at the values
% rx(1)=0.6, rx(2)=-1.4 and mantain the reference rx(3) for x(3) as a free
% parameter, specify options.fixref.x=[1 2], options.valueref.x=[0.6 -1.4].
%
% Note: @MPC objects from MPC Toolbox are no longer supported, as they are handled 
% directly in the MPC Toolbox since R2014b.
%
% See also EXPCON/EVAL for the order states and references are stored
% inside the parameter vector.

% (C) 2003-2014 by A. Bemporad

info=struct('rCheb',[],'flattol',[],'colors',[],'islin',[],'ishyb',[],...
    'ismpc',[],'name',[],...
    'lintracking',[],'isconstr',[],'refsignals',[],'refsize',[],...
    'fixref',[],'valueref',[],'fixmd',[],'valuemd',[]);

if nargin<1,
%     C=struct('H',[],'K',[],'F',[],'G',[],'i1',[],'i2',[],'nr',[],'thmin',[],'thmax',[],'nu',[],...
%         'rCheb',[],'npar',[],'flattol',[],'ts',[],'colors',[],'islin',[],'ishyb',[],...
%         'ismpc',[],'name',[],'model',[],'nx',[],...
%         'ny',[],'lintracking',[],'isconstr',[],'Observer',[],'refsignals',[],'refsize',[],...
%         'fixref',[],'valueref',[],'fixmd',[],'valuemd',[],'norm',[],'cost',[]);
    C=struct('H',[],'K',[],'F',[],'G',[],'i1',[],'i2',[],'nr',[],'thmin',[],'thmax',[],...
        'nu',[],'npar',[],'ts',[],'model',[],'nx',[],'ny',[],'Observer',[],'norm',[],'cost',[],...
        'info',info);
    C=class(C,'expcon');
    return;
end


%-----------------
% Check controller
%-----------------
if ~isa(con,'lincon') && ~isa(con,'hybcon') && ~isa(con,'mpc'),
    error('Invalid controller');
end

islin=isa(con,'lincon');
ishyb=isa(con,'hybcon');
ismpc=isa(con,'mpc');

if ~ismpc,
    ny=con.ny;
    nx=con.nx;
    nu=con.nu;
    nv=0;
else
    error('@MPC objects are no more supported in the Hybrid Toolbox, they are handled in the MPC Toolbox since R2014b.');
end

if ishyb,
    nrx=length(con.ref.x);
    nru=length(con.ref.u);
    nry=length(con.ref.y);
    nrz=length(con.ref.z);
    if nrz>0,
        error('Reference signals for z-vectors cannot be specified for explicit hybrid controllers');
    end
    lintracking=0;
else
    nry=0;
    nrx=0;
    nru=0;
    nrz=0;
    if islin,
        lintracking=strcmp(con.type,'track');
    else % ismpc
        lintracking=1;
    end
end


%-----------------
% Check options
%-----------------
valuedef=struct('x',[],'u',[],'y',[]);
fixdef=struct('x',[],'u',[],'y',[]);
optdef=struct('lpsolver','glpk','qpsolver','qpact','fixref',fixdef,'valueref',valuedef,...
    'fixmd',[],'valuemd',[],'noslack',0,...
    'flattol',1e-6,'waitbar',1,'verbose',0,'mplpverbose',1,'uniteeps',1e-3,...
    'join',1,'reltol',1e-6,'sequence',0);
if nargin<3 || isempty(options),
    options=optdef;
end
if islin,
    options=chkoptions(options,1,optdef);
elseif ishyb,
    if isempty(con.pwa),
        aux='You should first convert the MLD model to PWA form (type "%s.pwa=pwa(%s)").';
        warnmsg=sprintf(aux,inputname(1),con.model);
        warning(warnmsg);
        con.pwa=evalin('caller',sprintf('pwa(%s);',con.model));
        assignin('caller',inputname(1),con);
    end

    nxr=con.pwa.nxr;
    nxb=con.pwa.nxb;
    nur=con.pwa.nur;
    nub=con.pwa.nub;
    nyr=con.pwa.nyr;
    nyb=con.pwa.nyb;

    options=chkoptions(options,2,optdef,con.ref.y,con.ref.x,con.ref.u,nxr,nxb,nur,nub,nyr,nyb);
    thenorm=con.norm;
end

nrx=nrx-length(options.fixref.x);
nry=nry-length(options.fixref.y);
nru=nru-length(options.fixref.u);

%-----------------
% Check range
%-----------------

% Define default range
large=1000;
clear Pdef
if islin && lintracking,
    Pdef.umin=-large*ones(nu,1);
    Pdef.umax=large*ones(nu,1);
end
if islin,
    if lintracking,
        %nx= original state-space size
        Pdef.refymin=-large*ones(ny,1);
        Pdef.refymax=large*ones(ny,1);
    end
else
    Pdef.refymin=-large*ones(nry,1);
    Pdef.refymax=large*ones(nry,1);
    Pdef.refxmin=-large*ones(nrx,1);
    Pdef.refxmax=large*ones(nrx,1);
    Pdef.refumin=-large*ones(nru,1);
    Pdef.refumax=large*ones(nru,1);
    %Pdef.refzmin=-large*ones(nrz,1);
    %Pdef.refzmax=large*ones(nrz,1);
end
Pdef.xmin=-large*ones(nx,1);
Pdef.xmax=large*ones(nx,1);

if nargin<2 || isempty(range),
    range=Pdef;
end
range=chkrange(range,islin+2*ishyb,nx,nu,ny,Pdef,lintracking,nrx,nru,nry,nv-1); %,nrz);

%--------------------
if islin,
    if ~lintracking
        % Regulator: U=qp(H,x'*F,G,W+K*x);
        thmin=range.xmin(:);
        thmax=range.xmax(:);
    else
        % Tracking controller: U=qp(H,[x;u;r]'*F,G,W+K*[x;u;r]);
        thmin=[range.xmin(:);range.umin(:);range.refymin(:)];
        thmax=[range.xmax(:);range.umax(:);range.refymax(:)];
    end
    %try
    envelope=0;
    mpqpsol=mpqp(con.Q,con.C,con.G,con.W,con.S,thmin,thmax,options.verbose,...
        options.qpsolver,options.lpsolver,envelope,[],[],options.reltol);
    [C,colors]=getcontroller(mpqpsol,nu,options.uniteeps,options.reltol,...
        options.join,options.lpsolver,options.sequence);
    info.rCheb=C.rCheb;
    info.flattol=C.flattol;
    C=rmfield(C,'rCheb');
    C=rmfield(C,'flattol');

    info.nvar=size(con.Q,1); % number of optimization variables

    %catch
    %rethrow(lasterror);
    %end
elseif ishyb

    % Prepare PWAOPT setup

    clear setup
    setup.xmin=-Inf*ones(nx,1);
    setup.xmin(con.limits.ixmin)=con.limits.xmin;
    setup.xmax=Inf*ones(nx,1);
    setup.xmax(con.limits.ixmax)=con.limits.xmax;
    setup.umin=-Inf*ones(nu,1);
    setup.umin(con.limits.iumin)=con.limits.umin;
    setup.umax=Inf*ones(nu,1);
    setup.umax(con.limits.iumax)=con.limits.umax;
    setup.ymin=-Inf*ones(ny,1);
    setup.ymin(con.limits.iymin)=con.limits.ymin;
    setup.ymax=Inf*ones(ny,1);
    setup.ymax(con.limits.iymax)=con.limits.ymax;

    setup.LPsolver=options.lpsolver;
    setup.norm=thenorm;

    setup.fixref=options.fixref;
    setup.valueref=options.valueref;

    %     aux=setdiff((1:nyr),con.refsignals.y); % continuous outputs not tracked
    %     setup.fixref.y=[setup.fixref.y(:);aux(:)];
    %     setup.valueref.y=[setup.valueref.y(:);0*aux(:)];
    %
    %     aux=setdiff((1:nxr),con.refsignals.x); % continuous states not tracked
    %     setup.fixref.x=[setup.fixref.x(:);aux(:)];
    %     setup.valueref.x=[setup.valueref.x(:);0*aux(:)];
    %
    %     aux=setdiff((1:nur),con.refsignals.u); % continuous inputs not tracked
    %     setup.fixref.u=[setup.fixref.u(:);aux(:)];
    %     setup.valueref.u=[setup.valueref.u(:);0*aux(:)];

    setup.flattol=options.flattol;
    setup.waitbar=options.waitbar;
    setup.verbose=options.verbose;
    setup.mplpverbose=options.mplpverbose;
    setup.uniteeps=options.uniteeps;

    setup.x0min=range.xmin; % Set of initial states where the mp-problem is solved
    setup.x0max=range.xmax;

    % Set of continuous output references where the mp-problem is solved
    setup.y0refmin=range.refymin;
    setup.y0refmax=range.refymax;
    ii=find(setdiff(con.refsignals.y,options.fixref.y)>nyr);
    setup.y0refmin(ii)=[];
    setup.y0refmax(ii)=[];

    % Set of continuous state references where the mp-problem is solved
    setup.x0refmin=range.refxmin;
    setup.x0refmax=range.refxmax;
    ii=find(setdiff(con.refsignals.x,options.fixref.x)>nxr);
    setup.x0refmin(ii)=[];
    setup.x0refmax(ii)=[];

    % Set of continuous input references where the mp-problem is solved
    setup.u0refmin=range.refumin;
    setup.u0refmax=range.refumax;
    ii=find(setdiff(con.refsignals.u,options.fixref.u)>nur);
    setup.u0refmin(ii)=[];
    setup.u0refmax(ii)=[];

    % The following should be moved to HYBCON/BUILD to improve MILP on-line
    % optimization
    %     % Any integer state/input to be fixed ?
    %     nxb=con.pwa.nxb;
    %     nub=con.pwa.nub;
    %     xbmin=range.xmin(nxr+1:nxr+nxb);
    %     xbmax=range.xmax(nxr+1:nxr+nxb);
    %     ubmin=range.umin(nur+1:nur+nub);
    %     ubmax=range.umax(nur+1:nur+nub);
    %     if any(xbmax<0) | any(xbmin>1),
    %         error('Infeasible range for binary states');
    %     end
    %     if any(ubmax<0) | any(ubmin>1),
    %         error('Infeasible range for binary input');
    %     end
    %     setup.xbfix1=find(xbmin>0); % Indices of binary states to be fixed at 1
    %     setup.xbfix0=find(xbmax<1);
    %     setup.ubfix1=find(ubmin>0);
    %     setup.ubfix0=find(ubmax<1);

    % Retrieve terminal constraint
    setup.Sx=con.limits.Sx;
    setup.Tx=con.limits.Tx;

    % Slack variable for soft constraints ?
    setup.noslack=ischar(con.epsvar); % hybcon.epsvar ='hard state constraints';

    % Retrieve weights
    nxb=con.pwa.nxb;
    Qx=zeros(nx,nx);
    [n1,n2]=size(con.Q.x);
    Qx(con.refsignals.x,con.refsignals.x)=[con.Q.x;zeros(n2-n1,n2)];
    setup.Qc=Qx(1:nxr,1:nxr);
    setup.Qb=Qx(nxr+1:nxr+nxb,nxr+1:nxr+nxb);
    if norm(Qx(1:nxr,nxr+1:nxr+nxb),'inf')~=0 | norm(Qx(nxr+1:nxr+nxb,1:nxr),'inf')~=0,
        error('Mixed weights on continuous and binary states are not allowed, Q.x must be block diagonal');
    end
    if isinf(thenorm),
        % Remove rows of zeros
        idiff=setdiff(1:nx,con.refsignals.x);
        icdiff=idiff(find(idiff<=nxr));
        ibdiff=idiff(find(idiff>nxr));
        setup.Qc(icdiff,:)=[];
        setup.Qb(ibdiff-nxb,:)=[];
    end

    QxN=zeros(nx,nx);
    [n1,n2]=size(con.Q.xN);
    QxN(con.refsignals.x,con.refsignals.x)=[con.Q.xN;zeros(n2-n1,n2)];
    setup.Pc=QxN(1:nxr,1:nxr);
    setup.Pb=QxN(nxr+1:nxr+nxb,nxr+1:nxr+nxb);
    if norm(QxN(1:nxr,nxr+1:nxr+nxb),'inf')~=0 || norm(QxN(nxr+1:nxr+nxb,1:nxr),'inf')~=0,
        error('Mixed weights on continuous and binary terminal states are not allowed, Q.xN must be block diagonal');
    end
    if isinf(thenorm),
        setup.Pc(icdiff,:)=[];
        setup.Pb(ibdiff-nxb,:)=[];
    end

    nub=con.pwa.nub;
    Qu=zeros(nu,nu);
    [n1,n2]=size(con.Q.u);
    Qu(con.refsignals.u,con.refsignals.u)=[con.Q.u;zeros(n2-n1,n2)];
    setup.Rc=Qu(1:nur,1:nur);
    setup.Rb=Qu(nur+1:nur+nub,nur+1:nur+nub);
    if norm(Qu(1:nur,nur+1:nur+nub),'inf')~=0 | norm(Qu(nur+1:nur+nub,1:nur),'inf')~=0,
        error('Mixed weights on continuous and binary inputs are not allowed, Q.u must be block diagonal');
    end
    if isinf(thenorm),
        % Remove rows of zeros
        idiff=setdiff(1:nu,con.refsignals.u);
        icdiff=idiff(find(idiff<=nur));
        ibdiff=idiff(find(idiff>nur));
        setup.Rc(icdiff,:)=[];
        setup.Rb(ibdiff-nur,:)=[];
    end

    nyb=con.pwa.nyb;
    Qy=zeros(ny,ny);
    [n1,n2]=size(con.Q.y);
    Qy(con.refsignals.y,con.refsignals.y)=[con.Q.y;zeros(n2-n1,n2)];
    setup.Yc=Qy(1:nyr,1:nyr);
    setup.Yb=Qy(nyr+1:nyr+nyb,nyr+1:nyr+nyb);
    if norm(Qy(1:nyr,nyr+1:nyr+nyb),'inf')~=0 || norm(Qy(nyr+1:nyr+nyb,1:nyr),'inf')~=0,
        error('Mixed weights on continuous and binary outputs are not allowed, Q.y must be block diagonal');
    end
    if isinf(thenorm),
        % Remove rows of zeros
        idiff=setdiff(1:ny,con.refsignals.y);
        icdiff=idiff(find(idiff<=nyr));
        ibdiff=idiff(find(idiff>nyr));
        setup.Yc(icdiff,:)=[];
        setup.Yb(ibdiff-nyr,:)=[];
    end
    if norm(con.Q.z,'inf')~=0,
        error('Weights on continuous auxiliary variables are not allowed');
    end
    setup.rho=con.Q.rho;
    setup.refsignals=con.refsignals;

    setup.mpqpverbose=0;
    if setup.norm==2,
        setup.qpsolver=options.qpsolver;
    end
    setup.sequence=options.sequence;
    [sol,lpsolved,colors]=pwaopt(con.pwa,con.horizon,setup);
    if isinf(setup.norm),
        costs=[];
    else
        costs=sol.cost;
        sol=rmfield(sol,'cost');
    end
    info.rCheb=sol.rCheb;
    info.flattol=sol.flattol;
    info.colors=colors;
    info.nvar=sol.nvar;
    
    C=rmfield(sol,{'nvar','type','unconstr_num','label','rCheb','flattol'});
end

C.ts=con.ts;
if C.npar==2, % Colors only meaningful for 2D partitions
    info.colors=colors;
else
    info.colors=[];
end
info.islin=islin;
info.ishyb=ishyb;
info.ismpc=ismpc;
info.name=inputname(1);
info.sequence=options.sequence;

if islin || ishyb,
    C.model=con.model;
    C.nx=con.nx;
    C.ny=con.ny;
else
    C.model={Mat.A,Mat.Bu,Mat.Bv,Mat.Cm,Mat.Dvm};
    C.nx=nx;
    C.ny=ny;
end

if islin,
    info.lintracking=lintracking;
    info.isconstr=con.isconstr;
    
    % For backwards compatibility:
    if iscell(con.Observer),
        con.Observer=con.Observer{1};
    end

    C.Observer=con.Observer;
    info.refsignals=[];
    info.refsize=[];
    info.fixref=[];
    info.valueref=[];
    info.fixmd=[];
    info.valuemd=[];
    C.norm=2;
    if ~isa(C.model,'cell'),
        Udata=con.model.Userdata;
    else
        Udata=con.model{1}.Userdata;
    end
    sHm=Udata.sHm;
    C.cost=struct('Q',con.Q*sHm,'C',con.C*sHm,'G',con.G,'W',con.W,'S',con.S,'Y',Udata.Y*sHm);
elseif ishyb,
    info.lintracking=NaN;
    info.isconstr=1;
    C.Observer=NaN;
    info.refsignals=con.refsignals;
    % info.refsize contains the number of ref signals that have not been fixed
    % to a given value
    info.refsize=struct('y',nry,'x',nrx,'u',nru);
    info.fixref=options.fixref;
    info.valueref=options.valueref;
    info.fixmd=[];
    info.valuemd=[];
    C.norm=setup.norm;
    C.cost=costs;
end
C.info=info;

C=class(C,'expcon');