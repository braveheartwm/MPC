function plot(varargin)
%PLOT Plot polyhedral partitions associated with explicit controller (only 2D) 
% 
%  PLOT(expcon) plots the polyhedral partition corresponding to the
%  explicit controller 'con'. Only 2-D plots are supported. 
%  If the parameters are more than two, plots can be obtained through PLOTSECTION.
%
%  PLOT(expcon,fighandle) also specifies the handle of the figure where the
%  partition should be plotted. For subplots, use fighandle='xyz', where (x,y) 
%  define the number of subplots and z the subplot number. 
%  Example: PWAPLOT(sol,[],'221') plots the partition in subplot(2,2,1)
%
%  PLOT(expcon,fighandle,pauseflag) pause after each plotting 
%  each cell if pauseflag=1  
%
%  PLOT(expcon,fighandle,pauseflag,overlap) plots multiple (possibly
%  overlapping) partitions in the same screen if overlap=1
%
%  PLOT(expcon,fighandle,pauseflag,overlap,xlab,ylab) also specifies
%  x-label and y-label

%
% (C) 2003-2005 by A. Bemporad

if nargin<1,
    error('expcon:move:none','No EXPCON object supplied.');
end
expcon=varargin{1};
if ~isa(expcon,'expcon'),
    error('expcon:move:obj','Invalid EXPCON object');
end
sol=struct(expcon);

if nargin<2,
    pwaplot(sol,sol.info.colors);
else
    pwaplot(sol,sol.info.colors,varargin{2:end});
end
    

