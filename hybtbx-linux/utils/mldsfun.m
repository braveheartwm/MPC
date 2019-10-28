%  MLDSFUN S-function for @MLD systems
% 
%  Usage: [sys,x0,str,Ts] = MLDSFUN(t,x,u,flag,S)
% 
%  Masked inputs:
%          S = @MLD object
%  Inputs: u=inputs
% 
%  State:  state of hybrid MLD system 
% 
%  Outputs: x(t), y(t)=C*x(t), delta(t-1), z(t-1). We assume that y(t) only 
%  depends on x(t), and return delta(t-1) and z(t-1) to avoid direct feedthrough 
%  from u(t) to delta, z, y.
% 
%  (C) 2003-2009 by A. Bemporad
