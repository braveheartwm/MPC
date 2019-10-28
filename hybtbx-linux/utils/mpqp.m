%  MPQP: Multiparametric quadratic optimization
% 
%  mpqpsol=mpqp(Q,C,A,b,S,thmin,thmax,verbose,qpsolver,lpsolver,envelope)
% 
%  Multiparametric quadratic optimization.
% 
%  Parametrically solve the quadratic programming problem:
% 
%  min  .5*x'Qx+th'*C'*x
% 
%  s.t. A*x <= b + S*th
% 
%  where the parameters th are furthermore bounded in the region
% 
%  thmin <= th <= thmax.
% 
% 
%  The output of the function are neighboring convex polytopes
%  in the th-space along with the optimal solution for each region.
%  The solution is stored in the structure mpqpsol with fields:
% 
%  H,K,i1,i2:    Region #i is stored in H(i1(i):i2(i),:),K(i1(i):i2(i),:)
%  F,G:          Gain #i is stored in F((i-1)*n+1:i*n,:), G((i-1)*n+1:i*n)
%  rCheb:        Chebischev radius of region #i
%  act,i3,i4:    Combination of active constraints of region #i is stored in act(i3(i):i4(i),:)
%  unconstr_num: Region number for the region where no constraints are active
% 
%  nr=Number of regions=length(i1)
% 
% 
% 
%  DIMENSIONS:
%  A(qxn), b(qx1), S(qxm), C(qxm), Q(nxn), where q are the number of constraints,
%  n=number of x-variables; m=number of th-parameters
% 
%  verbose=2: plots intermediate results
%         =0: nothing
%         =1: show messages
%  qpsolver= supported QP solver (type HELP QPSOL)
%  lpsolver= supported LP solver (type HELP LPSOL)
% 
%  envelope =1 also computes the polyhedral hyperplane representation of the set of
%  feasible parameters, i.e., of the union of the critical regions. This is
%  stored in mpqpsol.Aenv, mpqpsol.Benv (default: envelope=0).
% 
%  mpqp(Q,C,A,b,S,thmin,thmax,verbose,qpsolver,lpsolver,envelope,Hth,Kth)
%  only computes the regions of the feasible set of parameters that intersect
%  the polyhedron {th: H*th <= K}
% 
%  mpqp(Q,C,A,b,S,thmin,thmax,verbose,qpsolver,lpsolver,envelope,Hth,Kth,flattol)
%  eliminates partitions whose Chebychev radius is smaller than flattol and
%  enlarge the other regions so that no hole remains.
% 
%  (C) 2003-2004 by A. Bemporad
