% HWRITE: hwrite(C) writes the data of the explicit controller C in the file EXPCON.H
% 
%   HWRITE(C) write the header file EXPCON.H for the state-feedback 
%   or output-feedback explicit controller C.
% 
%   HWRITE(C,zerotol) also specifies a tolerance for considering small numbers 
%   as true zeros.
% 
%   HWRITE(C,zerotol,type) also specifies the type ('int', 'float', or
%   'double') for storing the parameters defining the polyhedral cells of
%   the solution.
% 
%   In addition, the following syntax is valid for output-feedback controllers 
%   based on linear models:
% 
%   HWRITE(C,zerotol,type,u1) also specifies the previous input at 
%   time t=-1 (only meaningful for tracking controllers).
% 
%   HWRITE(C,zerotol,type,u1,x0) also specifies the initial condition 
%   for the state observer (only meaningful for output-feedback controllers).
% 
%   In case of time-varying prediction models, only use the first model
%   for state estimation purposes.
% 
%  (C) 2003-2009 by A. Bemporad
