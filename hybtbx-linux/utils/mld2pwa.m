%  P=MLD2PWA(S,xmax,umax,options)
% 
%  Given the hybrid MLD system S (obtained e.g. from HYSDEL), returns the PWA system P
% 
%  xc(t+1)=A(i)xc(t)+B(i)uc(t)+f(i)    x=[xc;xl], u=[uc;ul]
%  xl(t+1)=LA(i)xc(t)+LA(i)u(c)+Lf(i)  if Hx(i)x(t)+Hu(i)u(t)<=K(i)
%  yc(t+1)=C(i)xc(t)+D(i)uc(t)+g(i)       y=[yc;yl]
%  yl(t+1)=LC(i)xc(t)+LD(i)uc(t)+Lg(i)    
% 
%  The bounds -xmax<=x<=xmax, -umax<=u<=umax are added in the definition of the
%  polyhedral cell, unless xmax=Inf, umax=Inf. 
% 
%  Note that integer states and inputs are included in the x and u vectors, respectively.
% 
%  options.method = 'sequential': Sequence of MILPs (default)
%                 = 'recursive' : Recursive method
% 
%  options.verbose=1: plots intermediate results
%                 =0: nothing
%                 =2: also show results of MILP
%  options.lpsolver=   LP solver (type "help lptype" for available options) 
%  options.milpsolver= MILP solver. Valid options are:
%       'dantz'   uses DANTZGMP.DLL 
%       'glpk'    uses GLPKMEX.DLL 
%       'nag'     uses MIQP3_NAF.M based on E04MBF or E04MF for LP
%       'matlab'  uses MIQP3_NAF.M based on LP.M for LP
%       'cplex'   uses MILP_CPLEX.DLL
%  options.tighteps             Tolerance which decides if two dynamics (A,B,f) are equal (default:1e-6)
% 
%  The bounds -xmax<=x<=xmax, -umax<=u<=umax are added in the definition of the
%  polyhedral cell, unless xmax=Inf, umax=Inf.
% 
%  Reference:
%  A. Bemporad, ``Efficient conversion of mixed logical dynamical systems into 
%  an equivalent piecewise affine form,'' IEEE Trans. Automatic Control, 
%  vol. 49, no. 5, pp. 832-838, May 2004.
% 
%  (C) 2003 by A. Bemporad
