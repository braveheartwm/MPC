% Linear time-varying MPC of a time-varying linear system
%
% This demo shows how the Hybrid Toolbox can handle time-varying linear
% prediction models. 
%
% The following controllers are compared: 
% (1) linear MPC controller based on a time-invariant model, which is updated at each time step;
% (2) linear MPC controller based on a time-varying prediction model;
% (3) linear MPC controller based on a time-invariant average model.

% (C) 2009 by A. Bemporad

clear variables

useKalman=1;

interval.N=5;
interval.Nu=2;

cost.S=1;
cost.T=1e-2;

limits.umin=0;
lims.umax=3;

Tstop=30;          % Simulation time
x0=[0 0]';         % Initial state of the plant
r=1;               % Output reference trajectory
Ts=1;

TT=round(Tstop/Ts); % Number of simulation steps

sys=tf(1,[6 1.5 1]);
sys=ss(c2d(sys,Ts)); % prediction model

% Create array of model structures
model=cell(TT+interval.N,1);
for i=1:TT+interval.N,
    g=sin(i/2);
    model{i}=sys;
    model{i}.C=sys.C*(1+0.5*g);
end

% Controller based on average LTI model, which is model{1}
C3=lincon(model{1},'track',cost,interval,limits);
if useKalman,
    % Kalman filter matrices
    Qk=eye(2);
    Rk=.1;
    [dummy,M3]=kalman(C3,Qk,Rk);
end

% Closed loop simulation: MPC controller based on LTI model, updated at each time step t
YY1=[];
UU1=[];
XX1=[];
x=x0;
u=0;
xh=x0;

fprintf('Simulating MPC controller based on LTI model, updated at each time step t:          ');

for t=0:TT-1,
    fprintf('.');
    XX1=[XX1,x];

    themodel=model{t+1};

    % Prepare MPC controllers for next time step
    C1=lincon(themodel,'track',cost,interval,limits);
    if useKalman,
        [dummy,M1]=kalman(C1,Qk,Rk);
    end

    % Plant equations: output update  (note: no feedthrough from MV to Y, D(:,1)=0)
    y=themodel.C*x;
    YY1=[YY1,y];
    
    if useKalman,
        % State estimate: measurement update
        xh=xh+M1*(y-themodel.C*xh); % assume matrix D=0
    else
        xh=x;
    end
    % Compute MPC law
    u=u+eval(C1,xh,r,u);
    
    % Plant equations: state update
    x=themodel.A*x+themodel.B*u;

    if useKalman,
        % State estimate: time update
        xh=themodel.A*xh+themodel.B*u;
    end
    UU1=[UU1,u];
end
fprintf('\n');

% Closed loop simulation: MPC controller based on time-varying model, updated at each time step t
YY2=[];
UU2=[];
XX2=[];
x=x0;
u=0;
xh=x0;

fprintf('Simulating MPC controller based on time-varying model, updated at each time step t: ');
for t=0:TT-1,
    fprintf('.');
    XX2=[XX2,x];

    themodel=model{t+1};
    
    C2=lincon(model(t+1:t+interval.N),'track',cost,interval,limits);
    if useKalman,
        [dummy,M2]=kalman(C2,Qk,Rk);
    end
    % Plant equations: output update  (note: no feedthrough from MV to Y, D(:,1)=0)
    y=themodel.C*x;
    YY2=[YY2,y];
    
    if useKalman,
        % State estimate: measurement update
        xh=xh+M2*(y-themodel.C*xh); % assume matrix D=0
    else
        xh=x;
    end
    % Compute MPC law

    du=eval(C2,xh,r,u);
    
    u=u+du;
    % Plant equations: state update
    x=themodel.A*x+themodel.B*u;
    
    if useKalman,
        % State estimate: time update
        xh=themodel.A*xh+themodel.B*u;
    end
    UU2=[UU2,u];
end
fprintf('\n');

% Closed loop simulation: MPC controller based on average LTI model
YY3=[];
UU3=[];
XX3=[];
x=x0;
u=0;
xh=x0;

fprintf('Simulating MPC controller based on average LTI model:                               ');
for t=0:TT-1,
    fprintf('.');
    XX3=[XX3,x];

    themodel=model{t+1};
    % Plant equations: output update  (note: no feedthrough from MV to Y, D(:,1)=0)
    y=themodel.C*x;
    YY3=[YY3,y];
    
    if useKalman,
        % State estimate: measurement update
        xh=xh+M3*(y-C3.model.C*xh); % assume matrix D=0
    else
        xh=x;
    end
    % Compute MPC law
    u=u+eval(C3,xh,r,u);
    
    % Plant equations: state update
    x=themodel.A*x+themodel.B*u;
    
    if useKalman,
        % State estimate: time update
        xh=C3.model.A*xh+C3.model.B*u;
    end
    UU3=[UU3,u];
end
fprintf('\n');

% Plot results and compare the MPC controllers
close all
subplot(211)
plot(0:Ts:Tstop-Ts,YY1,'--',0:Ts:Tstop-Ts,YY2,0:Ts:Tstop-Ts,YY3,'-.');% ,0:Ts:Tstop-1,dcgains,':')
grid
legend('updated LTI model','time-varying model','average LTI model')
title('Output');
subplot(212)
plot(0:Ts:Tstop-Ts,UU1,'--',0:Ts:Tstop-Ts,UU2,0:Ts:Tstop-Ts,UU3,'-.')
grid
title('Input');