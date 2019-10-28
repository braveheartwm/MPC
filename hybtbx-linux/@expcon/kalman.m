function [Kest,M]=kalman(expcon,Q,R,ymeasured)
% KALMAN Design Kalman filter for constrained optimal controllers
%
% See also KALMANHELP.

% (C) 2003-2009 by Alberto Bemporad

if nargin<1,
    error('expcon:kalman:none','No EXPCON object supplied.');
end
if ~isa(expcon,'expcon'),
    error('expcon:kalman:obj','Invalid controller object');
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

[expcon,Kest,M]=kalmdesign(struct(expcon),Q,R,ymeasured);
expcon=class(expcon,'expcon');

assignin('caller',inputname(1),expcon);
if nargout==0,
    clear Kest M
end