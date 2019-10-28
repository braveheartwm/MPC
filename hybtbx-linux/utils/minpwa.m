%  MINPWA: Compute the minimum of convex PWA functions
% 
%  nsol=minpwa(sols,setup)
% 
%  sols=array of mplp solutions:  sols(i)=mplp solution #i
% 
%  nsol=(nonconvex) min pwa function and partition  
%  
%  setup is a structure with fields:
% 
%  .LPsolver='nag'     uses E04MBF or E04MF (depending on NAG version)
%           ='matlab'  uses LP.M 
%           ='glpk'    uses GLPK Revised Simplex Method (default)
%           ='dantz'   uses DANTZGMP.DLL for LP
%           ='cdd'     uses CDDMEX.DLL for LP
% 
%  .verbose   = 2: plots intermediate results (2D only)
%             = 0: minimal
%             = 1: show messages
%             =-1: no printout
% 
%  .join      ='cost' join regions where the value function is the same after solving
%                mpLPs. In so doing, the optimizer function maybe lost.
%             ='optimizer' join regions where the optimizer function is the same.
% 
%  .flattol   regions flatter than 'flattol' are removed
%  .waitbar   = 0 No waitbar
% 
%  NOTE: The solution may not be exact where the value function is
%  discontinuous, due to the overlapping of the regions and the way the
%  explicit solution is computed. The exact solution can be computed by
%  comparing all the values given on the regions whose facet is overlapping
%  on the discontinuity point.
% 
%  (C) 2003 by A. Bemporad
