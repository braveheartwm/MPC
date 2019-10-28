function [flag,x0,U,xf,X,T,D,Z,Y,reachtime]=reach(S,N,Xf,X0,umin,umax,milpsolver)   
% REACH Reachability analysis of MLD systems
%
% flag=REACH(S,N,Xf,X0,umin,umax) determines if the state of the MLD system S 
% can reach the target set Xf after exactly N steps, starting from the set of initial 
% conditions X0 and by applying inputs u(0),..., u(N-1) in [umin,umax].
%
% flag=1 if Xf is reachable from X0 by applying some input u within the given bounds, 
% flag=0 if Xf cannot be reached from X0.
% flag=-1 if Xf is reachable from X0, but the counterexample could not be
% verified (usually for numerical roundoff errors).
% 
% flag=REACH(S,[1 N],Xf,X0,umin,umax) determines if the state of the MLD system S 
% can reach the target set Xf at some time k, 1<=k<=N, starting from the 
% set of initial conditions X0 and by applying inputs u(0),..., u(N-1) 
% in [umin,umax].
%
% The sets are specified as structures:
%
% X0 is a structure with fields 'A','b' defining the polyhedron X0={x: X0.A*x(0)<=X0.b}.
% Xf is a structure with fields 'A','b' defining the polyhedron Xf={x: Xf.A*x(N)<=Xf.b}.
% X0,Xf are polyhedra of R^nx, where nx = number of continuous and binary
% states. 
% umin and umax are vectors of dimension nu = number of continuous and binary inputs.
%
% [flag,x0,U]=REACH(S,N,Xf,X0,umin,umax) also returns an initial condition
% x0 in X0 and a sequence of inputs U with values in Uset which lead to a final 
% state in Xf. U is the sequence of inputs, with as many columns as the number of inputs.
% 
% [flag,x0,U,xf,X,T,D,Z,Y]=REACH(S,N,Xf,X0,umin,umax) also returns the final
% state xf and the sequence of states X, time steps T (equally spaced by S.Ts), 
% auxiliary binary variables D, auxiliary continuous variables Z, outputs Y.
%
% [flag,x0,U,xf,X,T,D,Z,Y]=REACH(S,N,Xf,X0,umin,umax,milpsolver) also specifies 
% the type of MILP solver to be used for computations (for valid types type "help milptype").
%
% [flag,x0,U,xf,X,T,D,Z,Y,reachtime]=REACH(S,[1 N],Xf,X0,...) also returns 
% the vector reachtime of times k at which x(k) belongs to Xf.
%
% Note: Complex reachability analysis queries can be addressed by adding conditions 
% (such as linear constraints, logical constraints) in the MUST section of the hysdel file 
% that defines the MLD model S.
%
% (C) 2005 by Alberto Bemporad

if nargin<2 | isempty(N),
    N=1;
end
if ~isnumeric(N),
    error('Number of steps N must be a positive integer');
end
if any(floor(N)~=N),
    Nfloor(N);
    error(sprintf('Number of steps N has been rounded to %d',N(end)));
end
N=N(:)';

if length(N)==1,
    exactflag=1;
else
    exactflag=0;
end

if ~exactflag & N(1)~=1,
    error('Reachability horizon must have the form [1 N]');
end
N=N(end);

if N<1,
    N=1;
    exactflag=1;
    error('Number of steps N has been increased to 1');
end

nx=S.nx;
if nargin<3 | isempty(Xf),
    warning('Empty final state set, assuming Xf = the origin');
    Xf=struct('A',[eye(nx);-eye(nx)],'b',zeros(2*nx,1)+10*eps);
end
if ~isa(Xf,'struct') | ~isfield(Xf,'A') | ~isfield(Xf,'b'),
    error('Xf must be a structure with fields ''A'' and ''b''');
end

if nargin<4 | isempty(X0),
    warning('Empty initial state set, assuming X0 = all possible MLD states');
    b=getbounds(S);
    X0=struct('A',[eye(nx);-eye(nx)],'b',[b.xmax(:);-b.xmin(:)]);
end
if ~isa(X0,'struct') | ~isfield(X0,'A') | ~isfield(X0,'b'),
    error('X0 must be a structure with fields ''A'' and ''b''');
end

nu=S.nu;
if nargin<5 | isempty(umin),
    umin=-Inf*ones(nu,1);
end
if nargin<6 | isempty(umax),
    umax=Inf*ones(nu,1);
end

% Tighten input bounds
b=getbounds(S);
umin=max(umin(:),b.umin(:));
umax=min(umax(:),b.umax(:));

if any(umin>umax),
    error('Input set is empty (some lower bound is greater than its corresponding upper bound)');
end

if nargin<7 | isempty(milpsolver),
    milpsolver=S.milpsolver;
end

if ~exactflag, % Reachability test over all k\in[1,N]
    
    % Augment the MLD system to register the entrance of the target (unsafe) set Xf:
    % 1) a new variable deltaU(k), where [deltaU(k)=1] -> [x(k+1)\in Xf]
    % 2) add the constraint sum(k=0,...,N-1) deltaU(k)>=1
    %
    % Note: deltaU is appended as the last delta var
    
    % Get big-M bounds
    nXf=length(Xf.b);
    M=zeros(nXf,1);
    for i=1:nXf,
        aux=lpsol(-Xf.A(i,:),[eye(nx);-eye(nx)],[b.xmax(:);-b.xmin(:)]);
        M(i)=Xf.A(i,:)*aux-Xf.b(i);
    end
    
    % Add big-M inequalities: Xf.A*(A*x+B1*u+B2*d+B3*z)<=b+M(1-deltaU)
    S_orig=S;
    S.E2=[S.E2 zeros(S.ne,1);
        Xf.A*S.B2 M];
    S.nd=S.nd+1;
    S.E5=[S.E5;M+Xf.b];
    S.E4=[S.E4;-Xf.A*S.A];
    S.E1=[S.E1;-Xf.A*S.B1];
    S.E3=[S.E3;Xf.A*S.B3];
    S.ne=S.ne+nXf;
    S.B2=[S.B2,zeros(nx,1)];
    S.D2=[S.D2,zeros(S.ny,1)];
end

% Build a controller with horizon N
Q.norm=2;
Q.rho=Inf;

refsignals.x=[];
refsignals.y=[];
refsignals.z=[];
refsignals.u=1;

Q.x=[];
Q.u=1;
Q.z=[];
Q.y=[];

limits.umin=umin;
limits.umax=umax;
if exactflag, 
    limits.Sx=Xf.A; % This imposes x(N)\in Xf
    limits.Tx=Xf.b;
end

C=hybcon(S,Q,N,limits,refsignals);

% Variables: [u,d,z,x0]
nvar=size(C.H,1);
ivar=[C.ivar(:);nvar+(S.nxr+1:nx)']; % Add binary states as integer vars
n0=length(X0.b);
A=[C.A -C.Cx;
    zeros(n0,nvar) X0.A];
b=[C.b;X0.b];
f=zeros(nvar+nx,1); % pure feasibility test. 
% Note: If one would like to maximize the number of safety violations, one
% should optimize f=-onesvec (see below), i.e., max(sum(deltaU(k))).

if ~exactflag, 
    % Add inequality sum(deltaU(k))>=1:
    onesvec=f';
    dvar=C.dvar(1); % =initial position of vector d(0),...,d(N-1) within vector of vars
    for i=0:N-1,
        onesvec(dvar+(i+1)*S.nd-1)=1;
    end
    A=[A;
        -onesvec];
    b=[b;-1];
end

if ~exactflag, 
    S=S_orig;
end

vlb=[];
vub=[];
x0=[];
flag=0;

reachtime=[];

% Solve MILP
[xmin,flag]=milpsol(f,A,b,ivar,milptype(milpsolver),vlb,vub,x0);

if flag==1,
    if ~exactflag,
        reachtime=find(xmin(find(onesvec)));
    else
        reachtime=N;
    end
    
    % Eliminates roundoff problems when the solution is simulated with MLD/SIM
    
    xmin(ivar)=round(xmin(ivar)); % Roundoff binary components
    
    % Reoptimize continuous components
    b=b-A(:,ivar)*xmin(ivar);
    A(:,ivar)=[];
    lpsolver=milpsolver; % Use the same solver for LP
    
    % Compute Chebychev radius of the region Ax<=b (for continuous components)
    [nA,n]=size(A);
    ECheb=zeros(nA,1);
    for jj=1:nA,
        ECheb(jj)=norm(A(jj,:));
    end
    xguess=xmin;xguess(ivar)=[];xguess=[xguess;0];
    xopt=lpsol(-[zeros(n,1);1],[A,ECheb],b,[],[],xguess,[],[],lptype(lpsolver));
    rcheb=xopt(n+1);

    cvar=setdiff(1:length(xmin),ivar);
    xmin(cvar)=xopt(1:n);
    x0=xmin(nvar+1:nvar+nx);
    
    % Refines bounds, possibly violated beacuse of numerical roundoff
    x0=max(S.xl,x0); 
    x0=min(S.xu,x0); 
    
    % Further roundoff binary components
    x_ivar=(S.nxr+1:nx);
    x0(x_ivar)=round(x0(x_ivar)); 

    
    Useq=xmin(1:nu*N);
    U=zeros(N,nu);
    for i=1:N,
        U(i,:)=Useq((i-1)*nu+(1:nu))';
    end
    
    % Refines bounds, possibly violated beacuse of numerical roundoff
    ucmin=ones(N,1)*(S.ul(:))';
    ucmax=ones(N,1)*(S.uu(:))';
    U=max(ucmin,U); 
    U=min(ucmax,U); 
    
    % Further roundoff binary components
    u_ivar=(S.nur+1:nu);
    U(:,u_ivar)=round(U(:,u_ivar)); 

    if nargout>3,
        try
            [X,T,D,Z,Y,U,xf]=sim(S,x0,U);
        catch
            warning('Could not verify state trajectory, probably due to roundoff errors');
            T=(0:N-1)'*S.ts;
            X=[];
            D=[];
            Z=[];
            Y=[];
            xf=[];
            flag=-1;
        end
    end
else
    flag=0; % For any other output flag the MILP is considered infeasible
end

if flag==0, % Not reachable, or at least couldn't find a solution
    x0=NaN*ones(nx,1);
    U=NaN*ones(N,nu);
    if nargout>3,
        X=NaN*ones(N,nx);
        T=(0:N-1)'*S.ts;
        D=NaN*ones(N,S.nd);
        Z=NaN*ones(N,S.nz);
        Y=NaN*ones(N,S.ny);
        xf=x0;
    end
end