% Double Integrator Example

% (C) 2003 by Alberto Bemporad

clear variables

% Define the linear model (from input to constrained output)

Ts=1; % Sampling time
model=ss([1 1;0 1],[0;1],[0 1],0,Ts);

% Define the constrained optimal controller (implicit)
clear limits interval weights
limits.umin=-1;
limits.umax=1;
limits.ymin=-1; % Lower bound on x2

interval.Nu=2;
interval.N=2;

weights.R=.1; 
weights.Q=[1 0;0 0];  % Weight only x1
%weights.P=[1 0;0 1]; % User-defined P
weights.P='lqr'; % P=solution of Riccati Equation

%weights.P=[2.1429 1.2246;1.2246  1.3996]; % User-defined P
%weights.K=[-0.8166 -1.7499]; % user defined gain

weights.rho=+Inf; % Hard constraints on outputs, if present

% Optimal controller based on on-line optimization (implicit)
Cimp=lincon(model,'reg',weights,interval,limits);

% Closed-loop simulation
x0=[10,-.3]';
Tstop=40; %Simulation time
[X,U,T,Y]=sim(Cimp,model,[],x0,Tstop);

% Plot results
subplot(211)
plot(T,X);
xlabel('time')
ylabel('position, velocity')
grid

subplot(223)
plot(T,U);
xlabel('time')
ylabel('input')
grid

subplot(224)
plot(X(:,1),X(:,2),X(:,1),X(:,2),'d');
xlabel('position')
ylabel('velocity')
grid
set(gcf,'position',[   178   153   658   459]);
