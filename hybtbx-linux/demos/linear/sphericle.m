clear variables

% Continuous time system
A=[0 0 1 0;0 0 0 1 ;-66.2175 66.2175 -0.15 0 ;0 0 0 0];
B=[0 0 0 1]';
C=eye(4);
D=0;
sys=ss(A,B,C,D);

% Sampling tine
Ts=0.1;

% Convert model to discrete-time
sysd=c2d(sys,Ts);

% Setup constrained optimal controller

% Define cost function
T=0.0001;                  % weight on acceleration rate (=jerk)
S=diag([10000000 0 0 0]);  % output weight matrix (here output=state)
%                            Only weights angle
cost=struct('S',S,'T',T);
cost.rho=Inf; % hard constraints

% Define constraints: on acceleration and velocity
limits=struct('umin',-1,'umax',1,'ymin',[-Inf;-Inf;-Inf;-0.2],'ymax',[Inf;Inf;Inf;0.2]);
%limits=[]; % unconstrained

% Define horizons
moves=2; % number of free control moves
Nu=moves;  % Nu = input horizon    u(0),...,u(Nu-1)  
N=20;    % Optimal control horizon
interval=struct('Nu',Nu,'N',N);

% Optimal controller based on on-line optimization (implicit)
Cimp=lincon(sysd,'track',cost,interval,limits);

% Get the PWA representation of the controller (explicit)

% define range of parameters. Here parameters are states, previous input,
% output references
range=struct('xmin',-10,'xmax',10,'umin',-10,'umax',10,'refymin',-10,'refymax',10); 

% Compute explicit version of the controller
Cexp=expcon(Cimp,range);

% Plot a 2D section
plotsection(Cexp,3:9,[0 0 0 0 0 0 0]);
axis([-2 2 -1 1]);

% Closed-loop simulation

% Initial conditions
x0=zeros(4,1);
%x0=rand(4,1)*.5-.5;
u1=0; % Input at time -1

Tstop=10; %Simulation time
refs.y=[.5 0 0 0];
verbose=1;
qpsolver='qpact';

% Simulation using on-line optimization
figure
tic;sim(Cimp,sysd,refs,x0,Tstop,u1,qpsolver,verbose);toc

% Simulation using explicit controller
figure
tic;sim(Cexp,sysd,refs,x0,Tstop,u1,verbose);toc
% [X,U,T,Y,I]=sim(Cexp,sysd,refs,x0,Tstop,u1,verbose);

% Design a linear observer (Kalman filter)
kalman(Cexp)
