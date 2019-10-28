function [XX,TT,II,YY,UU,xT]=sim(P,x0,U,tol)
% SIM Simulate a PWA system from initial condition x0 and input sequence U
%
% [X,T,I,Y,U]=SIM(P,x0,U,tol) simulate the PWA system P from the initial condition 
% x0 (continuous and binary states) and for the sequence of inputs U 
% (continuous and binary). U has P.nu columns, one for each input.
%
% Output arguments:
% X is the sequence of states, with as many columns as the number of states.
% T is the vector of time steps (equally spaced by P.Ts).
% I is the sequence of switching modes.
% Y is the sequence of outputs, with as many columns as the number of outputs.
% U is the sequence of inputs, with as many columns as the number of inputs.
%
% The parameter tol (default: 1e-6) is used as a tolerance for assessing that
% Hx*x+Hu*u<=K.
%
% [X,T,I,Y,U,xT]=SIM(S,x0,U) also returns the final state xT=x(T).
%
% (C) 2003-2004 by Alberto Bemporad

nx=P.nx;
ny=P.ny;
nu=P.nu;
nxr=P.nxr;
nur=P.nur;

if nargin<4|isempty(tol),
    tol=1e-6;
end

if nargin<2|isempty(x0)|((nargin<3|isempty(U)) & nu>0),
    warning('The initial (state,input) pair was not completely assigned, looking for a feasible one via MILP');
    S=evalin('caller',P.mld);
    [x0,u]=getfeasible(S);
    U=ones(10,1)*u';
end

x0=x0(:);
Tstop=size(U,1); % Simulation runs for k=0, 1, ..., Tstop, t=Ts*k

if length(x0)~=nx,
    error(sprintf('The initial state must be a vector of dimension %d',nx));
end
if size(U,2)~=nu,
    error(sprintf('The matrix of input signals must have %d column(s), one per each input channel',nu));
end

XX=zeros(Tstop,nx);
II=zeros(Tstop,1);
YY=zeros(Tstop,ny);
TT=(0:Tstop-1)';

x=x0(:); % Current state x(t)
for t=1:Tstop,
    u = U(t,:)';
    XX(t,:)=x';
    try
        [xnext,y,i]=update(P,x,u);
    catch 
        error(sprintf('PWA infeasibility at simulation step k=%d !',t-1));
    end
    x=xnext;
    II(t)=i;
    YY(t,:)=y';
end
TT=TT*P.ts;

if nargout>=5,
    UU=U;
end
if nargout>=6,
    xT=x;
end