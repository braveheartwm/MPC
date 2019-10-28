%LINOBSMEX Explicit controller + observer for reference tracking - MEX interface
%
%   [u,reg]=LINOBSMEX(y,r,init) compute the control action u given 
%   the output measurements y(t) and the reference r(t). 
%
%   reg is the region number within the partition
%
%   The third argument init is used for resetting the controller states
%   to the default value:
%
%   [dummy1,dummy2]=LINOBSMEX(y,r,1) initializes the controller
%   [u,reg]=LINOBSMEX(y,r,0) computes the control move u and region reg.

%   (C) 2003 by Alberto Bemporad
