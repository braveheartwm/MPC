function [xnext,y,mode,x,u]=update(P,x,u)
% UPDATE Update hybrid dynamics: compute next state and auxiliary vars
%
% [xnext,y]=UPDATE(P,x,u) returns the state x(t+1) and output y(t) 
% produced by the PWA dynamics P, given x(t)=x, u(t)=u.
%
% [xnext,y,i]=UPDATE(P,x,u) also returns the current mode i.
%
% [xnext,y,i,x,u]=UPDATE(P) looks for a feasible state x and input u by
% solving an MILP on the original MLD system that generated P.
%
% See also PWA, PWA/SIM.

% (C) 2003 by Alberto Bemporad

if nargin<1,
    error('pwa:update:noPWA','No PWA object supplied.');
end
if ~isa(P,'pwa'),
    error('pwa:update:PWAobj','Invalid PWA object');
end

nx=P.nx;
nu=P.nu;

if nargin>=2 & (~isnumeric(x)|prod(size(x))~=nx),
    error(sprintf('State vector should be a vector of dimension %d',nx));
end
if nargin>=3 & (~isnumeric(u)|prod(size(u))~=nu),
    error(sprintf('Input vector should be a vector of dimension %d',nu));
end

if nargin<2|(isempty(x)& nx>0)|((nargin<3|isempty(u)) & nu>0),
    warning('The (state,input) pair was not assigned, looking for a feasible one via MILP');
    S=evalin('caller',P.mld);
    [x,u]=getfeasible(S);
end

% Find region where (x,u) lies
flag=7;
i=0;
tol=1e-6;
nxr=P.nxr;
nur=P.nur;
while flag==7 & i<P.nr,
    i=i+1;
    Pxui=P.Hx{i}*x;
    if nur>0,
        Pxui=Pxui+P.Hu{i}*u;
    end
    if all(Pxui<=P.K{i}+tol),
        flag=1;
        A=[P.A{i};P.LA{i}];
        B=[P.B{i};P.LB{i}];
        f=[P.f{i};P.Lf{i}];
        C=[P.C{i};P.LC{i}];
        D=[P.D{i};P.LD{i}];
        g=[P.g{i};P.Lg{i}];
    end
end
if (flag~=7),
    xnext=A*x(1:nxr)+f;
    if nur>0,
        xnext=xnext+B*u(1:nur);
    end
    y=C*x(1:nxr)+g;
    if nur>0,
        y=y+D*u(1:nur);
    end
    mode=i;
else 
    error('PWA infeasibility');
end

if nargout<2,
    clear y mode x u
end