%  LINSFUN S-function for @LINCON controllers.
% 
%  Usage: [sys,x0,str,Ts] = LINSFUN(t,x,yrd,flag,C,xhat0,u1)
% 
%  Masked inputs:
% 
%          C = @LINCON object
%  Inputs: xr=[measured state] (C.type='reg')
%          xr=[measured state;output reference] (C.type='track')
% 
%  State:  None 
% 
%  (C) 2003 by A. Bemporad
