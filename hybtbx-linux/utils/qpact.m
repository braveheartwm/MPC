% QPACT Solve quadratic program.
% 	[bas,ib,il,iter,tab]=qpact(tabi,basi,ibi,ili)
%
% Inputs:
%  tabi      : initial tableau
%  basi      : initial basis
%  ibi       : initial setting of ib
%  ili       : initial setting of il
%  maxiter   : max number of iteration (optional. Default=200)
%
% Outputs:
%  bas       : final basis vector
%  ib        : index vector for the variables -- see examples
%  il        : index vector for the lagrange multipliers -- see examples
%  iter      : iteration counter (=1e8 if maxiter is exceeded)
%  tab       : final tableau