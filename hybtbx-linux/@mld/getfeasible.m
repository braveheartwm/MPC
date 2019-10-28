function [x,u,d,z,y]=getfeasible(S,x0);
% GETFEASIBLE Get a feasible initial state x(0) and input u(0) for an MLD system
%
%  [x,u]=GETFEASIBLE(S) attempts at finding a feasible initial state x(0)
%  and input u(0) for the MLD system S. This is done by solving a
%  mixed-integer linear program on the MLD inequalities.
%
%
%  [x,u]=GETFEASIBLE(S,x0) attempts at finding a feasible input u(0) for
%  the MLD system S, given the initial state x(0).
%
%  [x,u,d,z]=GETFEASIBLE(S,x0) also returns the corresponding auxiliary binary
%  variables d(0) and z(0).
%
%  [x,u,d,z,y]=GETFEASIBLE(S,x0) also returns the corresponding output y(0).
%
% See also PWA/GETFEASIBLE, MLD/UPDATE, MLD/SIM.

%(C) 2003-2005 by Alberto Bemporad

nx=S.nx;
nu=S.nu;
nd=S.nd;
nz=S.nz;
nur=S.nur;
nxr=S.nxr;

% Look for bounds on states, inputs, z:
xmin=S.xl(:);
xmax=S.xu(:);
umin=S.ul(:);
umax=S.uu(:);
zmin=S.zl(:);
zmax=S.zu(:);

% umin=-Inf*ones(nu,1);
% umax=Inf*ones(nu,1);
% xmin=-Inf*ones(nx,1);
% xmax=Inf*ones(nx,1);
% zmin=-Inf*ones(nz,1);
% zmax=Inf*ones(nz,1);
% for i=1:length(S.symtable),
%     thesym=S.symtable{i};
%     if isfield(thesym,'min'),
%         isbin=strcmp(thesym.type,'b');
%         switch thesym.kind
%             case 'u'
%                 umin(thesym.index+isbin*nur)=thesym.min;
%                 umax(thesym.index+isbin*nur)=thesym.max;
%             case 'x'
%                 xmin(thesym.index+isbin*nxr)=thesym.min;
%                 xmax(thesym.index+isbin*nxr)=thesym.max;
%             case 'z'
%                 if ~isnan(thesym.min),
%                     zmin(thesym.index)=thesym.min;
%                 end
%                 if ~isnan(thesym.max),
%                     zmax(thesym.index)=thesym.max;
%                 end
%         end
%     end
% end            

if nargin<=1 | isempty(x0),
    nv=nu+nd+nz+nx;
    f=zeros(nv,1);
    A=[-S.E1 S.E2 S.E3 -S.E4];
    b=S.E5;
    ivar=[(nur+1:nu) (nu+1:nu+nd) (nu+nd+nz+nxr+1:nv)]';
    vlb=[umin;zeros(nd,1);zmin;xmin];
    vub=[umax;ones(nd,1);zmax;xmax];
else
    x0=x0(:);
    if length(x0)~=nx,
        error(sprintf('Dimension of x0 should be %d, you provided %d',nx,length(x0)));
    end
    nv=nu+nd+nz;
    f=zeros(nv,1);
    A=[-S.E1 S.E2 S.E3];
    b=S.E5+S.E4*x0;
    ivar=[(nur+1:nu) (nu+1:nu+nd)]';
    vlb=[umin;zeros(nd,1);zmin];
    vub=[umax;ones(nd,1);zmax];
end
[xmin,flag]=milpsol(f,A,b,ivar,milptype(S.milpsolver),vlb,vub);
if flag~=1,
    error('No feasible (state,input) pair was found');
end
    
% Roundoff binary components
xmin(ivar)=round(xmin(ivar));    
u=xmin(1:nu);
d=xmin(nu+1:nu+nd);
z=xmin(nu+nd+1:nu+nd+nz);

if nargin<=1 | isempty(x0),
    x=xmin(nu+nd+nz+1:nv);
else
    x=x0;
end

% Refines bounds, possibly violated beacuse of numerical roundoff
x=max(S.xl,x); 
x=min(S.xu,x); 
u=max(S.ul,u); 
u=min(S.uu,u); 

if nargout>4,
    y=S.C*x+S.D1*u+S.D2*d+S.D3*z;
end