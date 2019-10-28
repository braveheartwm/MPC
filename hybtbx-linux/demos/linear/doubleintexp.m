% Double Integrator Example

% (C) 2003 by Alberto Bemporad

clear variables

% Define the linear model

Ts=1; % Sampling time
model=ss([1 1;0 1],[0;1],[0 1],0,Ts);

% Define the constrained optimal controller (implicit)
clear limits interval weights
limits.umin=-1;
limits.umax=1;
%limits.ymin=-1;
%limits.ymax=Inf;

interval.Nu=2;
interval.N=2;

weights.R=.1; 
weights.Q=[1 0;0 0];
weights.P='lqr';     % P=solution of Riccati Equation
%weights.P=zeros(2);
weights.rho=+Inf; % Hard constraints on outputs, if present
%weights.rho=100; % Soft constraints on outputs, if present

% Optimal controller based on on-line optimization (implicit)
Cimp=lincon(model,'reg',weights,interval,limits);

% Get the PWA representation of the controller (explicit)
% Define range of states (=parameters)
%range=struct('xmin',[-2 -3],'xmax',[1 1]);
range=struct('xmin',[-15 -15],'xmax',[15 15]);

% Compute explicit version of the controller
Cexp=expcon(Cimp,range);
plot(Cexp)

axis([-15 15 -6 6]);

%latex(Cexp)
%hwrite(Cexp)

% Closed-loop simulation
x0=[10,-.3]';
Tstop=40; %Simulation time
[X,U,T,Y,I]=sim(Cexp,model,[],x0,Tstop);
hold on
plot(X(:,1),X(:,2),X(:,1),X(:,2),'d');
