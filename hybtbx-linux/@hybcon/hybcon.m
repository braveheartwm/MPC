function C=hybcon(MLD,Q,N,limits,refsignals,mipsolver)
%HYBCON Constructor for @HYBCON class -- Controller for a hybrid system
%
% P=HYBCON(MLD,Q,N) Build a hybrid controller based the optimal control
% problem
%
% min  (x(N)-r.x)'Q.xN(x(N)-r.x)+ \sum_{k=0}^{N-1} (y(k)-r.y)'Q.y(y(k)-r.y) + 
%          (u(k)-r.u)'Q.u(u(k)-r.u) + (z(k)-r.z)'Q.z(z(k)-r.z) +
%          \sum_{k=1}^{N-1}(x(k)-r.x)'Q.x(x(k)-r.x) + Q.rho*epsil^2
%
% s.t. MLD constraints
%            umin <= u(k) <= umax          k=0,...,N-1
%      ymin-epsil <= y(k) <= ymax+epsil    k=0,...,N-1
%      xmin-epsil <= x(k) <= xmax+epsil    k=1,...,N
%
% or 
%
% min  |Q.xN*(x(N)-r.x)|_\infty + \sum_{k=0}^{N-1} |Q.y*(y(k)-r.y)|_\infty + 
%          |Q.u*(u(k)-r.u)|_\infty + |Q.z*(z(k)-r.z)|_\infty +
%          \sum_{k=1}^{N-1}|Q.x*(x(k)-r.x)|_\infty + Q.rho*epsil
%
% s.t. same constraints.
%
% Input arguments:
%
% MLD = MLD system
% Q.y, Q.x, Q.u, Q.z, Q.rho, Q.xN = weights
% Q.norm = norm used (either 2 or Inf)
%         (default: Q.y=I, Q.x=0, Q.u=0.1*I, Q.z=0, Q.rho=+Inf, Q.xN=Q.x, Q.norm=Inf)
% N = control horizon  (default: N=1)
%
% The @HYBCON object has fields: 
%
%   H = Hessian (2-norm) or empty (Inf-norm)
%   f = linear term of cost function f'U
%   D = linear term of cost function theta'D'U (only 2-norm)
%   A = constraint matrix
%   b = constraint constant vector
%   Cx = constraint matrix for state vector x(t)
%   Cr = constraint matrix for reference r(t) (Inf-norm) or empty (2-norm)
%       Cr.y = constraint matrix for input reference vector ry
%       Cr.u = constraint matrix for input reference vector ru
%       Cr.x = constraint matrix for state reference vector rx
%       Cr.z = constraint matrix for z-reference vector rz
%   ivar = integer vars
%   uvar = position of vector u(0),...,u(N-1) within vector of vars
%   dvar = position of vector d(0),...,d(N-1) within vector of vars
%   zvar = position of vector z(0),...,z(N-1) within vector of vars
%   model = name of MLD variable which the controller is based on
%   name = name of HYSDEL model which generated the MLD model
%     ts = sampling time of the controller (inherited from MLD's sampling time) 
%
% P=HYBCON(MLD,Q,N,LIMITS) also specifies the structure LIMITS
% of upper and lower bounds on outputs, states and inputs:
%
%    .umin = lower bounds on inputs            [ u(k)>=umin ]
%    .umax = upper bounds on inputs            [ u(k)<=umax ]
%    .ymin = lower bounds on outputs           [ y(k)>=ymin-epsil ]
%    .ymax = upper bounds on outputs           [ y(k)<=ymax+epsil ]
%    .xmin = lower bounds on states            [ x(k)>=xmin-epsil ]
%    .xmax = upper bounds on states            [ x(k)<=xmax+epsil ]
%    .Sx, .Tx = terminal state constraint      [ Sx*x(N)<=Tx+epsil ]
%
% Limits on states and outputs are hard constraints if Q.rho=+Inf, otherwise soft constraints.
%
% Note that input and state constraints can be alternatively specified directly in
% the hysdel model.
%
% P=HYBCON(MLD,Q,N,LIMITS,REFSIGNALS) also specifies a structure REFSIGNALS
% denoting output/state/input/z variables for which a reference is specified:
%
% REFSIGNALS.y = indices of outputs for which a reference signal is provided.
% REFSIGNALS.u = indices of inputs for which a reference signal is provided.
% REFSIGNALS.x = indices of states for which a reference signal is provided.
% REFSIGNALS.z = indices of z-vectors for which a reference signal is provided.
%
% Q.y must have dimension = length(REFSIGNALS.y) 
% Q.u must have dimension = length(REFSIGNALS.u) 
% Q.x must have dimension = length(REFSIGNALS.x) 
% Q.z must have dimension = length(REFSIGNALS.z) 
% Q.rho must have dimension = 1 
% Q.xN must have dimension = length(REFSIGNALS.x) 
%
% Example: the MLD system has 3 outputs and 2 inputs, and we want only
% outputs y1 and y3 to track certain reference signals r1, r3,
% and no reference trajectories for inputs, states, and z-variables.
% You must set REFSIGNALS.y=[1 3], REFSIGNALS.u=[], REFSIGNALS.x=[], 
% REFSIGNALS.z=[], Q.y=<2-by-2 matrix>, Q.u=[], Q.x=[], Q.z=[], Q.xN=[].
%
% P=HYBCON(MLD,Q,N,LIMITS,REFSIGNALS,mipsolver) also specifies the type of
% MIP solver to be used for computations (valid types are 'glpk',
% 'cplex' for MILP and 'miqp' and 'cplex' for MIQP). The default MILP solver 
% is the one specified in MLD.milpsolver, the default MIQP solver is 'miqp'

% (C) 2003-2004 by A. Bemporad

if nargin<1,
    C=struct('Cr',[],'H',[],'D',[],'Y',[],'f',[],'A',[],'b',[],'Cx',[],'ivar',[],'Q',[],'uvar',[],...
        'dvar',[],'zvar',[],'epsvar',[],'refsignals',[],'mipsolver',[],'limits',[],'norm',[],...
        'name',[],'model',[],'nx',[],'ny',[],'nu',[],'nz',[],'ts',[],'horizon',[],'pwa',[],...
        'hysmodel',[]);
    C=class(C,'hybcon');    
    return
end

if ~isa(MLD,'mld'),
    error('hybcon:getindex:obj','Invalid MLD object');
end

if nargin<2,
    Q=[];
end
if nargin<3|isempty(N),
    N=1;
end
if nargin<4,
    limits=[];
end
if nargin<5,
    refsignals=[];
end
if nargin<6,
    mipsolver=[];
end

try
    C=buildmip(MLD,Q,N,limits,refsignals,mipsolver);
catch
    rethrow(lasterror);
end
C.name=MLD.name;
C.model=inputname(1);
C.nx=MLD.nx;
C.ny=MLD.ny;
C.nu=MLD.nu;
C.nz=MLD.nz;
C.ts=MLD.ts;
C.horizon=N;
C.pwa=[];
C.hysmodel=MLD.hysmodel;
C=class(C,'hybcon');