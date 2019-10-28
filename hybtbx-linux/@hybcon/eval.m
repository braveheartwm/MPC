function [u,xnext,y,d,z]=eval(hybcon,MLD,r,x,solver,verbose,tilim)
% EVAL Control move based on MILP o MIQP optimization and MLD model 
%
% u=EVAL(hybcon,MLD,r,x) returns the control move u(t)=f(x(t),r(t)) 
% where x(t)=x is the current state and r(t)=r is the current reference.
%
% Input: hybcon      = hybrid controller (type HELP HYBCON for details)
%        MLD         = MLD system
%        r.y,r.x,r.u,r.z = references (see HYBCON, HYBCON/SIM)
%        x           = current state
%
% [u,xnext,y,d,z]=EVAL(hybcon,MLD,r,x) also returns the next
% state xnext=x(t+1), output y(t), delta(t) and z(t).
%
% [u,...]=EVAL(hybcon,MLD,r,x,solver,verbose,tilim) also allows specifying:
%   solver      = 'cplex', 'glpk' ,... (type "help milpsol" or "help miqpsol" for further
%                  options). Default is hybcon.mipsolver
%   verbose     = verbosity level of MIP solver
%
%   tilim       = time limit for solving the MIP. The best solution found by the solver 
%                 within the time limit is used (only GLPK and CPLEX supported)
%
% See also HYBCON, HYBCON/SIM, MILPSOL, MIQPSOL.

% (C) 2003-2004 by Alberto Bemporad

if nargin<1,
    error('hybcon:eval:none','No HYBCON object supplied.');
end
if ~isa(hybcon,'hybcon'),
    error('hybcon:eval:obj','Invalid HYBCON object');
end
if nargin<2,
    error('hybcon:eval:noMLD','No MLD object supplied.');
end
if ~isa(MLD,'mld'),
    error('hybcon:eval:MLDobj','Invalid MLD object');
end

if nargin<5 | isempty(solver),
    solver=hybcon.mipsolver;
end
if nargin<6 | isempty(verbose),
    verbose=0;
end
if nargin<7,
    tilim=[];
end

nry=length(hybcon.refsignals.y);
nrx=length(hybcon.refsignals.x);
nru=length(hybcon.refsignals.u);
nrz=length(hybcon.refsignals.z);

if nargin<3|isempty(r),
    r=struct('y',zeros(1,nry),'x',zeros(1,nrx),'u',zeros(1,nru),'z',zeros(1,nrz));
else
    if ~isa(r,'struct'),
        error('reference r must be a structure with fields ''x'', ''u'', ''z''');
    end
end
if isfield(r,'y'),
    ry=r.y(:);
    if length(ry)~=nry,
        error(sprintf('Output reference %s.y must be a vector of length %d',inputname(3),nry));
    end
else
    ry=zeros(nry,1);
end
if isfield(r,'x'),
    rx=r.x(:);
    if length(rx)~=nrx,
        error(sprintf('State reference %s.x must be a vector of length %d',inputname(3),nrx));
    end
else
    rx=zeros(nrx,1);
end
if isfield(r,'u'),
    ru=r.u(:);
    if length(ru)~=nru,
        error(sprintf('Input reference %s.u must be a vector of length %d',inputname(3),nru));
    end
else
    ru=zeros(nru,1);
end
% if isfield(r,'d'),
%    rd=r.d;
% else
%    rd=zeros(nrd,1);
% end
if isfield(r,'z'),
    rz=r.z(:);
    if length(rz)~=nrz,
        error(sprintf('Reference %s.z must be a vector of length %d',inputname(3),nrz));
    end
else
    rz=zeros(nrz,1);
end

if nargin<4|isempty(x),
    x=zeros(MLD.nx,1);
end
x=x(:);

thenorm=hybcon.norm;
if isinf(thenorm)
    nv=size(hybcon.f(:),1);
    f=hybcon.f;
else
    nv=size(hybcon.H(:),1);
    H=hybcon.H;
    D=hybcon.D;
    theta=[x;rx;ry;ru;rz];
    f=D*theta;
end
ivar=hybcon.ivar;
A=hybcon.A;

b=hybcon.b+hybcon.Cx*x;
if isinf(thenorm)
if ~isempty(ry),
    b=b+hybcon.Cr.y*ry;
end
if ~isempty(rx),
    b=b+hybcon.Cr.x*rx;
end
if ~isempty(ru),
    b=b+hybcon.Cr.u*ru;
end
if ~isempty(rz),
    b=b+hybcon.Cr.z*rz;
end
end

vlb=[];
vub=[];
x0=[];

if isinf(thenorm)
    [xmin,flag]=milpsol(f,A,b,ivar,milptype(solver),vlb,vub,x0,verbose,tilim);
else
    [xmin,flag] = miqpsol(H,f,A,b,ivar,miqptype(solver),vlb,vub,x0,verbose,tilim);
end

if ~(flag==1 || flag==2) 
    %if verbose>=1,
    if isinf(thenorm)
        warning(sprintf('MILP not succeded, exit flag=%d',flag));
    else
        warning(sprintf('MIQP not succeded, exit flag=%d',flag));
    end
    %end
    xmin=NaN*ones(size(f));
    if flag==-2,
        warning(sprintf('Try increasing time limit, currently %f s',tilim));
    end
end

u=xmin(hybcon.uvar(1:hybcon.nu));

if nargout>=2,
   d=xmin(hybcon.dvar(1:MLD.nd));
   z=xmin(hybcon.zvar(1:MLD.nz));
   
   xnext=MLD.A*x;
   
   if ~isempty(u),
      xnext=xnext+MLD.B1*u;   
   end
   if ~isempty(d),
      xnext=xnext+MLD.B2*d;
   end
   if ~isempty(z),
      xnext=xnext+MLD.B3*z;
   end
end
%[d,z,flag]=dzfind(x,u,MLD,solv);

if nargout>=3,
   y=MLD.C*x;
   if ~isempty(u),
      y=y+MLD.D1*u;   
   end
   if ~isempty(d),
      y=y+MLD.D2*d;
   end
   if ~isempty(z),
      y=y+MLD.D3*z;
   end
end
