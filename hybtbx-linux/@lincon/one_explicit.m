%  Activeset=ONE_EXPLICIT(lincon,theta,U,la,noregion) computes the active set
%  and the corresponding critical region and gain for the QP problem
%  associated with the LINCON object lincon. U and la are the (optional) primal and dual
%  solutions of the QP problem when the vector of parameters is theta.
%  If the optional flag noregion=1, the critical region is not computed.
% 
%  Activeset is a structure with fields:
% 
%  Activeset.i = indices of active constraints. The combination of active constraints
%                is reduced to get a matrix of active constraints with linearly independent rows
% 
%  Activeset.H and .K  = polyhedral representation of critical region
%                {H*th<=K}, where th is either x (regulation) or [x;u;r]
%                (tracking)
% 
%  Activeset.Rcheb = Chebychev radius of the critical region {H*th<=K}
% 
%  Activeset.F and .G  = optimal feedback gain u=F*th+G
% 
%  (C) 2010 by A. Bemporad
%
%    Other functions named one_explicit
%
%       lincon/one_explicit
