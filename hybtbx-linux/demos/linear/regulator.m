% Regulation of a SISO system
%
% (C) 2003 by Alberto Bemporad

clear variables

% prediction model
Ts=.5;     %Sampling time

A=[0 0;
    1 -2];
B=[1;0];
C=[1 1];
D=0;
sys=ss(A,B,C,D);
model=c2d(sys,Ts);

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
range=struct('xmin',-5,'xmax',5);

% Compute explicit version of the controller
Cexp=expcon(Cimp,range);
%plot(Cexp); 
%legend off

% Closed-loop simulation

x10=2;
x20=3;
x0=[x10;x20]';
Tstop=30; %Simulation time
% [X,U,T,Y,I]=sim(Cexp,model,[],x0,Tstop);
% hold on
% plot(X(:,1),X(:,2),X(:,1),X(:,2),'d');
% 
% 
% open_system('regulatorsim');
% sim('regulatorsim');
open_system('regulatorsimexp');
sim('regulatorsimexp');
