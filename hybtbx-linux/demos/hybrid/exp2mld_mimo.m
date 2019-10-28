% Convert to hybrid dynamics the closed-loop explicit MPC example 7.2 from the following reference:
%
% A. Bemporad, M. Morari, V. Dua, and E.N. Pistikopoulos, ``The explicit linear 
% quadratic regulator for constrained systems,'' Automatica, vol. 38, no. 1, 
% pp. 3-20, 2002. 
%
% (C) 2015 by A. Bemporad

close all
clear variables

% Defines the linear MIMO model
plant=tf(10,[100 1])*[4 -5;-3 4];
Ts=1; %Sampling time
model=ss(c2d(plant,Ts));

[ny,nu]=size(model.D);
nx=size(model.A,1);

% Define the cost function
T=.1*eye(nu); % input weight matrix
S=eye(ny);    % output weight matrix
cost=struct('S',S,'T',T);
cost.rho=Inf; % hard constraints

% Define the constraints
limits=struct('umin',-ones(nu,1),'umax',ones(nu,1));

% Define the horizons
Nu=1;  % number of free control moves
N=20;  % prediction horizon
interval=struct('N',20,'Nu',Nu);

% Creates linear MPC controller based on QP
C=lincon(model,'track',cost,interval,limits);

% Convert the controller to explicit piecewise affine form:

% range of parameters over which the solution is determined
xmax=100*ones(nx,1);
refymax=10*ones(ny,1);
range=struct('xmin',-xmax,'xmax',xmax,'umin',limits.umin-1,'umax',limits.umax+1,'refymin',-refymax,...
    'refymax',refymax); 

con=expcon(C,range); % Actual conversion
nr=con.nr;

% Plot section of control law
sp=[0.63;0.79]; % Desired output set-point change from equilibrium

plotsection(con,[nx+1:nx+nu+ny],[zeros(1,nu) sp']); % Plot partition

% Simulate closed-loop linear MPC system
x0=zeros(nx,1);  % Initial state
Tstop=200;       % Simulation time (seconds)

refs=struct('y',sp');

%[X,U,T,Y,I]=sim(con,model,refs,x0,Tstop); % Simulate using expcon/sim

x=x0;
Y=[];
U=[];
I=[];
X=[];
T=Tstop/Ts;
u0=[0;0];
for t=1:T,
    X=[X;x'];
    [Du,reg]=eval(con,[x;u0;sp]);
    u=u0+Du;
    y=con.model.C*x+con.model.D*u;
    x=con.model.A*x+con.model.B*u;
    Y=[Y;y'];
    U=[U;u'];
    u0=u;
    I=[I;reg];
end
T=0:T-1;
R=ones(numel(T),1)*sp';

% Now convert the closed-loop system to hybrid dynamical form
S=exp2mld(con);

% Design a hybrid MPC controller for the obtained hybrid system to generate
% set-points to the underlying explicit MPC controller

ny=con.ny;
nreg=con.nr;
% Only weights the difference between the desired setpoint and setpoint optimized via MILP
Q=struct('u',diag([ones(ny,1);zeros(nreg,1)]),'norm',Inf); 

N=1; % prediction horizon of hybrid MPC controller
hybC=hybcon(S,Q,N);

xh0=[x0;zeros(nu,1)]; % initial state of hybrid dynamical system = [x(0);u(-1)]

% Simulate closed-loop hybrid MPC system
[Xh,Uexth,Dh,Zh,Th,Yh]=sim(hybC,S,struct('u',[sp' zeros(1,nreg)]),xh0,1+max(T)*hybC.ts);

Rh=Uexth(:,1:ny); % generated reference signal to the closed-loop system
Ih=Uexth(:,ny+1:end)*(1:size(Uexth,2)-ny)'; % region number of explicit MPC controller
Uh=zeros(numel(Th),nu);
for i=1:nu,
    Uh(:,i)=sum(Zh(:,i:nu:nu*nr)')'; % applied control input to the linear system
end

% Plot results

figure('name','Explicit vs hybrid MPC');

subplot(311)
plot(T,Y,T,R);
hold on
plot(Th,Yh,'--',Th,Rh,'--');
hold off
title('output');
legend('y(k) - explicit MPC', 'r(k) - explicit MPC', 'y(k) - hybrid MPC', 'r(k) - hybrid MPC');
grid

subplot(312)
plot(T,U);
hold on
plot(Th,Uh,'--');
hold off
title('input');
legend('u(k) - explicit MPC', 'u(k) - hybrid MPC');
grid

subplot(313)
stairs(T,I);
hold on
stairs(Th,Ih,'--');
hold off
title('region');
legend('i(k) - explicit MPC', 'i(k) - hybrid MPC');
grid


fprintf('Trajectory difference: outputs = %5.4g, inputs = %5.4g\n\n',norm(Y-Yh),norm(U-Uh));