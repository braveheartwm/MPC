% Regulation of a SISO system
%
% (C) 2003 by Alberto Bemporad

clear variables

% prediction model
Ts=.5;     %Sampling time
s = tf('s');
sys =(s+1) / (s^3+2*s^2+3*s+2);
model=c2d(ss(sys),Ts);

clear limits interval weights
limits.umin=-1;
limits.umax=1;
limits.dumin=-Inf;
limits.dumax=Inf;
limits.ymin=-Inf;
limits.ymax=Inf;

interval.N=2;

weights.R=.1; 
C=model.C;
weights.Q=C'*C; % Just weights the output
weights.P='lqr'; % P=solution to Riccati Equation

% Optimal controller based on on-line optimization (implicit)
Cimp=lincon(model,'reg',weights,interval,limits);

% Get the PWA representation of the controller (explicit)
% Define range of states (=parameters)
range=struct('xmin',-50,'xmax',50);

% Compute explicit version of the controller
Cexp=expcon(Cimp,range);
plotsection(Cexp,1,0); % Plot a section of the partition with x1=0;

legend off

% Closed-loop simulation
x0=[2 20 15]';
Tstop=200; %Simulation time
[X,U,T,Y,I]=sim(Cexp,model,[],x0,Tstop);
hold on
plot(X(:,2),X(:,3),X(:,2),X(:,3),'d');
