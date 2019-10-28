% Example #3

% (C) 2003 by Alberto Bemporad
clear variables

% Prepare parameters

Ts=.5;        %Sampling time

% Plant
sys=tf(1,[1 .4 1]);

% Prediction model
model=c2d(sys,Ts);

clear limits
% limits.umin=-Inf;
% limits.umax=Inf;
% limits.umin=0.8;  
% limits.umax=1.2;
limits.dumin=-0.2;
limits.dumax=0.2;

% WATCH OUT!!! If you set both u and du constraints,
%remember that the initial condition u(-1) should be set properly (e.g.:
%u(-1)=umin), otherwise the problem may be infeasible at time t=0.

clear cost
cost.S=1;      % Output weight
cost.T=.04;    % Input increment weight
cost.rho=Inf;  % Hard constraints (if present)

moves=10;
clear interval
interval.Nu=moves;        % input horizon    u(0),...,u(Nu-1)
interval.N=10;            % output horizon   \sum_{k=0}^{Ny-1}
interval.Ncu=moves-1;     % input constraints horizon    k=0,...,Ncu

C1=lincon(model,'track',cost,interval,limits);

clear ref
ref.y=ones(20,1);
x0=[0;0];
Tstop=10.0;   %Simulation time

sim(C1,model,ref,x0,Tstop);


open_system('example3sim');

% return

[y,t]=step(sys);
plot(t,y,'LineWidth',3);
grid
xlabel('time [s]','FontSize',24,'Interpreter','LaTeX');
ylabel('output $y(t)$','FontSize',24,'Interpreter','LaTeX');
h=get(gcf,'CurrentAxes');
set(h,'FontSize',24);
set(gcf,'Position',[209   313   557   520]);
set_param('example3sim/output','ForegroundColor','black')
