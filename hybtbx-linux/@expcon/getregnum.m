function [reg,x]=getregnum(expcon,n);
%GETREGNUM Pick up region numbers from 2D polyhedral plots.
%
%   See also EXPCON/GETGAIN

% (C) 2003 by Alberto Bemporad

if nargin<1,
    error('expcon:getregnum:none','No EXPCON object supplied.');
end
if ~isa(expcon,'expcon'),
    error('expcon:getregnum:obj','Invalid EXPCON object');
end

if nargin<2,
    [x,y]=ginput(1);
    [u,reg]=eval(expcon,[x;y]);
    x=[x;y];
else
      reg=[];
      x=[];
      for i=1:n,
      [x1,y1]=ginput(1);
        [u,reg(i)]=eval(expcon,[x1;y1]);
        x=[x;x1 y1];
   end
end
