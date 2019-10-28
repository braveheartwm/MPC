function [xnext,y,d,z,x,u]=update(S,x,u)
% UPDATE Update hybrid dynamics: compute next state and auxiliary vars
%
% xnext=UPDATE(S,x,u) returns the state x(t+1) produced by the MLD 
% dynamics S, given x(t)=x, u(t)=u.
%
% [xnext,y,d,z]=UPDATE(S,x,u) also returns the next
% state xnext=x(t+1), output y(t), delta(t), and z(t).
%
% [xnext,y,d,z,x,u]=UPDATE(S) looks for a feasible state x and input u by
% solving an MILP.
%
% See also HYBCON, HYBCON/SIM, HYSDEL.

% (C) 2003 by Alberto Bemporad

if nargin<1,
    error('mld:update:noMLD','No MLD object supplied.');
end
if ~isa(S,'mld'),
    error('mld:update:MLDobj','Invalid MLD object');
end

nx=S.nx;
nu=S.nu;

if nargin>=2 & (~isnumeric(x)|prod(size(x))~=nx),
    error(sprintf('State vector should be a vector of dimension %d',nx));
end
if nargin>=3 & (~isnumeric(u)|prod(size(u))~=nu),
    error(sprintf('Input vector should be a vector of dimension %d',nu));
end

if nargin<2,
    x=[];
end
if nargin<3,
    u=[];
end
if (isempty(x) & nx>0) | (isempty(u) & nu>0),
    warning('The (state,input) pair was not assigned, looking for a feasible one via MILP');
    [x,u]=getfeasible(S,x);
end

% Evaluate simulation file
eval(sprintf('[xnext,d,z,y]=%s(x,u,S.params);',S.simname));

if nargout<2,
    clear y d z x u
end