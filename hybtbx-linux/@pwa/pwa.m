function P = pwa(S,xmax,umax,options)
%PWA Constructor for @pwa class -- Hybrid PWA model
%
% P=PWA(S,xmax,umax,options)
%
% Given the hybrid MLD system S (obtained e.g. from HYSDEL), returns the PWA system P
%
%   xr(t+1)=A(i)xr(t)+B(i)ur(t)+f(i)     x=[xr;xb], u=[ur;ub]
%   xb(t+1)=LA(i)xr(t)+LB(i)ur(t)+Lf(i)  if Hx(i)x(t)+Hu(i)u(t)<=K(i)
%     yr(t)=C(i)xr(t)+D(i)ur(t)+g(i)     
%     yb(t)=LC(i)xr(t)+LD(i)ur(t)+Lg(i)  
%
% which is equivalent to S in the box -xmax <= x(t) <= xmax, -umax <= u(t) <= umax.
%
% Type PWAPROPS for a summary of the fields of PWA objects
%
% Note that integer states and inputs are included in the x and u vectors, respectively.
%
% options.method = 'sequential': Sequence of MILPs (default)
%                = 'recursive' : Recursive method
%
% options.verbose=1: plots intermediate results
%                =0: nothing
%                =2: also show results of MILP
% options.lpsolver=   LP solver (type "help lptype" for available options) 
% options.milpsolver= MILP solver. Valid options are:
%      'dantz'   uses DANTZGMP.DLL 
%      'glpk'    uses GLPKMEX.DLL 
%      'nag'     uses MIQP3_NAF.M based on E04MBF.M for LP
%      'matlab'  uses MIQP3_NAF.M based on LP.M for LP
%      'cplex'   uses MILP_CPLEX.DLL
% options.tighteps             Tolerance which decides if two dynamics (A,B,f) are equal (default:1e-6)
%
% The bounds -xmax<=x<=xmax, -umax<=u<=umax are added in the definition of the
% polyhedral cell, unless xmax=Inf, umax=Inf. 
%
% Reference:
% A. Bemporad, "Efficient Conversion of Mixed Logical Dynamical Systems into an Equivalent 
% Piecewise Affine Form", IEEE Transactions on Automatic Control, May 2004.
%
% See also PWAPROPS, MLD, HYSDEL.

%   (C) 2003 by A. Bemporad

if nargin<1,
    P=mld2pwa;
    P.nr=[];
    P.name=[];
    P.ts=[];
    P.mld=[];
    P.lpsolver=[];
    P.milpsolver=[];
    P.hysmodel=[];
else
    if ~isa(S,'mld'),
        error('pwa:getindex:obj','Invalid MLD object');
    end
    
    if nargin<2,
        xmax=[];
    end
    if nargin<3,
        umax=[];
    end
    if nargin<4,
        options=[];
    end
    
    [P,options]=mld2pwa(S,xmax,umax,options);
    P.name=S.name;
    P.ts=S.ts;
    P.mld=inputname(1);
    P.lpsolver=options.lpsolver;
    P.milpsolver=options.milpsolver;
    P.hysmodel=S.hysmodel;
end
P=class(P,'pwa');