% Example of linear MPC with variable input constraints

% (C) 2006 by Alberto Bemporad
clear variables

% Prepare parameters

Ts=.1;        %Sampling time

% Plant
sys=ss(tf(1,[1 .8 3]));

% Prediction model
model=c2d(sys,Ts);
[A,B,C,D]=ssdata(model);

% Add constant states umin,umax
A=[A, [0 0;0 0];
   0 0 1 0;
   0 0 0 1];
B=[B;0;0];

% Set y2=umin(t)-u(t), y3=umax(t)-u(t)
C=[C 0 0;
   0 0 1 0;
   0 0 0 1];
D=[D;-1;-1];
   
model=ss(A,B,C,D,Ts);

clear limits
limits.umin=-Inf;
limits.umax=Inf;
limits.ymin=[-Inf;-Inf;0];
limits.ymax=[Inf;0;Inf];

clear cost
cost.S=[1 0 0;0 0 0;0 0 0];      % Output weight
cost.T=.1;     % Input increment weight
cost.rho=Inf;  % Hard constraints

moves=4;
clear interval
interval.Nu=moves;        % input horizon    u(0),...,u(Nu-1)
interval.N=10;            % output horizon   \sum_{k=0}^{Ny-1}
interval.Ncu=moves-1;     % input constraints horizon    k=0,...,Ncu
interval.Ncy=moves-1;     % output constraints horizon    k=1,...,Ncy
yzerocon=1;               % check also output constraints for k=0

C1=lincon(model,'track',cost,interval,limits,[],yzerocon);

% Design state observer. Default Kalman design is not ok
Qn=[0.1 0 0 0;0 0.1 0 0;0 0 1e-5 0;0 0 1e-5 0];  % Variance of state noise
Rn=[1 0 0;0 0 0;0 0 0];    % Variance of output noise
ymeasured=[1 2 3];
C1=kalmdesign(C1,Qn,Rn,ymeasured)

clear ref
ref.y=ones(20,1);
x0=[0;0;0;0];
Tstop=20.0;   %Simulation time

open_system('varbounds_sim');
sim('varbounds_sim');