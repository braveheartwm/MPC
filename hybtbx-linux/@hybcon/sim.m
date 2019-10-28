function [XX,UU,DD,ZZ,TT,YY]=sim(hybcon,MLD,r,x0,Tstop,solver,verbose,tilim)
% SIM Closed-loop control of hybrid systems
%
% [X,U,D,Z,T,Y]=SIM(HYBCON,MLD,refs,x0,Tstop,solver,verbose,tilim) simulates
% the hybrid system MLD in closed-loop with the controller HYBCON.
% Usually, HYBCON is based on model MLD (nominal closed-loop).
%
% Input: hybcon      = hybrid controller
%        refs.y,refs.u,refs.x,refs.z = references
%        x0          = initial state
%	     Tstop       = total simulation time (e.g., in seconds)
%        solver      = 'glpk', 'cplex' (type "help milpsol" or "help miqpsol" for more options)
%        verbose     = verbosity level
%        tilim       = time limit for computing the MIP solution at each simultation step.
%
% refs.y has as many columns as the number of weighted outputs
% refs.x has as many columns as the number of weighted states
% refs.u has as many columns as the number of weighted inputs,
% refs.z has as many columns as the number of weighted auxiliary continuous variables. 
%
% Output arguments:
% X is the sequence of states, with as many columns as the number of states.
% U is the sequence of inputs, with as many columns as the number of inputs.
% D is the sequence of auxiliary binary variables
% Z is the sequence of auxiliary continuous variables
% T is the vector of time steps (equally spaced by MLD.Ts).
% Y is the sequence of outputs, with as many columns as the number of outputs.

% (C) 2003-2009 by Alberto Bemporad
if nargin<1,
    error('hybcon:sim:none','No HYBCON object supplied.');
end
if ~isa(hybcon,'hybcon'),
    error('hybcon:sim:obj','Invalid HYBCON object');
end
if nargin<2,
    error('hybcon:sim:noMLD','No MLD object supplied.');
end
if ~isa(MLD,'mld'),
    error('hybcon:sim:MLDobj','Invalid MLD object');
end
if nargin<6 || isempty(solver),
    solver=hybcon.mipsolver;
end
if nargin<7 || isempty(verbose),
    verbose=0;
end
if nargin<8,
    tilim=[];
end

A1=MLD.A;
B1=MLD.B1;
B2=MLD.B2;
B3=MLD.B3;
C=MLD.C;
D1=MLD.D1;
D2=MLD.D2;
D3=MLD.D3;
E1=MLD.E1;

% System Dimensions
nu   = size(B1,2);
nd   = size(B2,2);
nz   = size(B3,2);
nx   = size(A1,1);
ny   = size(C,1);

nry=length(hybcon.refsignals.y);
nrx=length(hybcon.refsignals.x);
nru=length(hybcon.refsignals.u);
nrz=length(hybcon.refsignals.z);

Tsteps=ceil(Tstop/hybcon.ts);
% Simulation runs for k=0, 1, ..., Tsteps

lintracking=0;
islin=0;
ishyb=1;
isexp=0;
refsdef=struct('y',zeros(1,nry),'x',zeros(1,nrx),'u',zeros(1,nru),'z',zeros(1,nrz));
if nargin<3 || isempty(r),
    r=refsdef;
end
[r,Tdef]=chkrefs(r,islin,ishyb,nrx,nru,nry,nrz,refsdef,lintracking,Tsteps,isexp);

if nargin<5 || isempty(Tstop),
    Tstop=Tdef*hybcon.ts;
end

    rx=r.x;
    ru=r.u;
%    rd=r.d;
    rz=r.z;
    ry=r.y;
  
if nargin<4 || isempty(x0),
    x0=zeros(nx,1);
else
    if ~isnumeric(x0) || length(x0)~=nx,
        error(sprintf('The initial state should be a vector of dimension %d',nx));
    end
    x0=x0(:);
end

XX=zeros(Tsteps,nx);
DD=zeros(Tsteps,nd);
ZZ=zeros(Tsteps,nz);
YY=zeros(Tsteps,ny);
UU=zeros(Tsteps,nu);
TT=(0:Tsteps-1)'*hybcon.ts;

x=x0(:); % Current state x(t)

thenorm=hybcon.norm;
if isinf(thenorm)
    f=hybcon.f;
else
    H=hybcon.H;
    D=hybcon.D;
end
ivar=hybcon.ivar;
A=hybcon.A;

if isinf(thenorm)
    solver=milptype(solver);
else
    solver=miqptype(solver);
end
xmin=[];

for t=1:Tsteps,
    if nrx>0,
        rxt=rx(t,:)';
    else
        rxt=[];
    end
    if nry>0,
        ryt=ry(t,:)';
    else
        ryt=[];
    end
    if nru>0,
        rut=ru(t,:)';
    else
        rut=[];
    end
    %    rdt=rd(t,:)';
    if nrz>0,
        rzt=rz(t,:)';
    else
        rzt=[];
    end
    
    b=hybcon.b+hybcon.Cx*x;
    if isinf(thenorm)
        if ~isempty(ryt),
            b=b+hybcon.Cr.y*ryt;
        end
        if ~isempty(rxt),
            b=b+hybcon.Cr.x*rxt;
        end
        if ~isempty(rut),
            b=b+hybcon.Cr.u*rut;
        end
        if ~isempty(rzt),
            b=b+hybcon.Cr.z*rzt;
        end
    end
    
%     if t==90,
%         keyboard;
%     end
    
    if isinf(thenorm)
        [xmin,flag] = milpsol(f,A,b,ivar,solver,[],[],xmin,verbose,tilim);
    else
        theta=[x;rxt;ryt;rut;rzt];
        f=theta'*D';
        [xmin,flag] = miqpsol(H,f,A,b,ivar,solver,[],[],xmin,verbose,tilim);
    end
    
    if (flag==1 || flag==2) 
        u=xmin(hybcon.uvar(1:nu));
    else 
        if isinf(thenorm)
            warning(sprintf('MILP not succeded at step %d, exit flag=%d -- Simulation stopped',t,flag));
        else
            warning(sprintf('MIQP not succeded at step %d, exit flag=%d -- Simulation stopped',t,flag));
        end
        if flag==-2,
            warning(sprintf('Try increasing time limit, currently %f s',tilim));
        end
        return
    end
    
    d=xmin(hybcon.dvar(1:nd));
    z=xmin(hybcon.zvar(1:nz));
    %[d,z,flag]=dzfind(x,u,MLD,solv);
    
    if verbose,
        fprintf('@ t=%d\n',t);
    end
    
    fprintf('.');
    if t/50==round(t/50),
        fprintf('\n');
    end
    
    y=C*x+D1*u+D2*d+D3*z;
    
    XX(t,:)=x';
    DD(t,:)=d';
    ZZ(t,:)=z';
    UU(t,:)=u';
    YY(t,:)=y';
    
    % disp(sprintf('t=%7.2f: x1=%7.2f, x2=%7.2f. MILP_FLAG=%d',t*Ts,x(1),x(2),flag))
    x=A1*x+B1*u+B2*d+B3*z;
    
    %X=[X,x];
end
fprintf('\n');
