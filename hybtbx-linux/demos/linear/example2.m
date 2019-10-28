% Example #1
%
% (C) 2003 by Alberto Bemporad
clear variables

% Prepare parameters

Ts=.2;        %Sampling time

% Plant
sys=tf(1,[1 2 1]);

% Prediction model
model=c2d(sys,Ts);

clear limits
limits.umin=-2;
limits.umax=2;

clear cost
cost.S=100;   % Output weight
cost.T=.1;    % Input increment weight
cost.rho=Inf; % Hard constraints

moves=2;
clear interval
interval.Nu=moves;        % input horizon    u(0),...,u(Nu-1)
interval.N=20;            % output horizon   \sum_{k=0}^{Ny-1}
interval.Ncu=moves-1;     % input constraints horizon    k=0,...,Ncu

Cimp=lincon(model,'track',cost,interval,limits);

clear range
range.xmax=[100;100];
range.xmin=-range.xmax;
range.umax=[50];
range.umin=-range.umax;
range.refymax=[20];
range.refymin=-range.refymax;

clear options
options.verbose=1;
options.reltol=1e-6;
options.uniteeps=1e-3;     % To by multiplied by tighteps to get tolerance to recognize same gain
%options.qpsolver='nag';    % Use E04NAF
options.qpsolver='qpact';  % Use active set QP

Cexp=expcon(Cimp,range,options);
%plotsection(Cexp,[3 4],[0 0])

% Design Kalman filter (default covariance matrices)
kalman(Cexp);

Tstop=20.0;   %Simulation time

open_system('example2sim');
sim('example2sim');

latex(Cexp,'example2'); % Write latex file specifying the controller