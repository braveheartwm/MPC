%EXPCONMEX Explicit hybrid/linear controller - State feedback - MEX interface
%
%   [u,reg]=EXPCONMEX(th) compute the control action u given 
%   the vector of parameters th(t).
%   
%   For linear regulators, th(t)=x(t) is the current state. 
%   For hybrid regulators, th(t)=[x(t);r(t)] also contains the reference 
%   signals.
%
%   reg is the region number within the partition
%
%
%   (C) 2003 by Alberto Bemporad
