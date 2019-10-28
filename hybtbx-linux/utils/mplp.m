% MPLP: Multiparametric linear optimization
% 
%  mplpsol=mplp(c,d,A,b,S,thmin,thmax,verbose,solver,envelope)
% 
%  Multiparametric linear optimization.
% 
%  Parametrically solve the linear programming problem:
% 
%  min  c'*x+d
% 
%  s.t. A*x <= b + S*th
% 
%  where the parameters th are furthermore bounded in the region
% 
%  thmin <= th <= thmax
% 
% 
%  The output of the function are neighboring convex polytopes
%  in the th-space along with the optimal solution for each region. The
%  solution is stored in the structure mplpsol with fields:
% 
%  H,K,i1,i2:    Region #i is stored in H(i1(i):i2(i),:),K(i1(i):i2(i),:)
%  F,G:          Gain #i is stored in F((i-1)*n+1:i*n,:), G((i-1)*n+1:i*n)
%  rCheb:        Chebischev radius of region #i
%  act,i3,i4:    Combination of active constraints of region #i is stored in act(i3(i):i4(i),:)
%  nr:           Number of regions=length(i1)
%  c,A,b,S:      Original mpLP problem matrices
% 
% 
%  DIMENSIONS:
%  A(qxn), b(qx1), S(qxm), c(nx1), where q are the number of constraints,
%  n=number of x-variables; m=number of th-parameters
% 
%  verbose=2: plots intermediate results (2D only)
%         =0: minimal
%         =1: show messages
%         =-1: no printout
% 
%  solver='nag'     uses E04MBF or E04MF for LP
%        ='matlab'  uses LP.M 
%        ='glpk'    uses GLPK Revised Simplex Method (default)
%        ='dantz'   uses QPACT.DLL for LP
%        ='cdd'     uses CDDMEX.DLL for LP
% 
%  envelope =1 also computes the polyhedral hyperplane representation of the set of
%  feasible parameters, i.e., of the union of the critical regions. This is
%  stored in mplpsol.Aenv, mplpsol.Benv (default: envelope=0).
% 
%  [mplpsol,lpsolved]=mplp(...) also return the number of solved LPs
% 
%  mplpsol=mplp(c,A,b,S,thmin,thmax,verbose,solver,envelope,H,K) only
%  computes the regions of the feasible set of parameters that intersect
%  the polyhedron {th: H*th <= K}
% 
%  NOTE: In case of primal degeneracy, or in case some theta-points happen to be on the boundary
%  among two (or more) regions, some regions may be overlapping. The cost function will 
%  be the same on overlaps, but the minimizer functions may be different. Holes will never appear.
%  See MPLPJOIN to obtain minimal nonoverlapping regions.
% 
%  (C) 2003-2009 by A. Bemporad
