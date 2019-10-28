function [XX,TT,DD,ZZ,YY,UU,xT]=sim(S,x0,U)
% SIM Simulate an MLD system from initial condition x0 and input sequence U
%
% [X,T]=SIM(S,x0,U) simulate the MLD system S from the initial condition 
% x0 (continuous and binary states) and for the sequence of inputs U 
% (continuous and binary). U has S.nu columns, one for each input.
%
% [X,T,D,Z,Y,U]=SIM(S,x0,U) returns the following trajectories:
%
% X is the sequence of states, with as many columns as the number of states.
% T is the vector of time steps (equally spaced by S.Ts).
% D is the sequence of auxiliary binary variables
% Z is the sequence of auxiliary continuous variables
% Y is the sequence of outputs, with as many columns as the number of outputs.
% U is the sequence of inputs, with as many columns as the number of inputs.
%
% [X,T,D,Z,Y,U,xT]=SIM(S,x0,U) also returns the final state xT=x(T).
%
% (C) 2003-2004 by Alberto Bemporad

if nargin<2|isempty(x0)| ((nargin<3|isempty(U)) & S.nu>0),
    warning('The initial (state,input) pair was not assigned, looking for a feasible one via MILP');
    [x0,u]=getfeasible(S);
    U=ones(10,1)*u';
end

x0=x0(:);
if length(x0)~=S.nx,
    error(sprintf('The initial state must be a vector of dimension %d',S.nx));
end
if size(U,2)~=S.nu,
    error(sprintf('The matrix of input signals must have %d column(s), one per each input channel',S.nu));
end

Tstop=size(U,1); % Simulation runs for k=0, 1, ..., Tstop, t=Ts*k

XX=zeros(Tstop,S.nx);
DD=zeros(Tstop,S.nd);
ZZ=zeros(Tstop,S.nz);
YY=zeros(Tstop,S.ny);
TT=(0:Tstop-1)';

x=x0(:); % Current state x(t)
for t=1:Tstop,
    u = U(t,:)';
    XX(t,:)=x';
    try
        [xnext,y,d,z]=update(S,x,u);
    catch
        a=lasterror;
        error(sprintf('Simulation aborted at time t=%g.\n%s',(t-1)*S.ts,a.message));
    end
    DD(t,:)=d';
    ZZ(t,:)=z';
    YY(t,:)=y';
    x=xnext;
end
TT=TT*S.ts;

if nargout>=6,
    UU=U;
end
if nargout>=7,
    xT=x;
end