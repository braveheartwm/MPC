function [Kest,M]=kalman(lincon,Q,R,ymeasured)
% KALMAN Design Kalman filter for constrained optimal controller
%
% See also KALMANHELP.

% (C) 2003-2009 by Alberto Bemporad

if nargin<1,
    error('lincon:kalman:none','No LINCON object supplied.');
end
if ~isa(lincon,'lincon'),
    error('lincon:kalman:obj','Invalid controller object');
end
if nargin<2,
    Q=[];
end
if nargin<3,
    R=[];
end
if nargin<4,
    ymeasured=[];
end

[lincon,Kest,M]=kalmdesign(struct(lincon),Q,R,ymeasured);
lincon=class(lincon,'lincon');

assignin('caller',inputname(1),lincon);
if nargout==0,
    clear Kest M
end