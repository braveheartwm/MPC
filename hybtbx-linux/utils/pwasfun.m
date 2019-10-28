%  PWASFUN S-function for @PWA systems
% 
%  Usage: [sys,x0,str,Ts] = PWASFUN(t,x,u,flag,S)
% 
%  Masked inputs:
%          S = @PWA object
%  Inputs: u=inputs
% 
%  State:  state of hybrid PWA system
% 
%  Outputs: x(t), y(t)=Ci*x(t)+gi, i(t).
% 
%  (C) 2003-2009 by A. Bemporad
