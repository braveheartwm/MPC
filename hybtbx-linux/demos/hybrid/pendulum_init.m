clear variables
close all

mass=1;
len=0.5;
g=9.81;
tau_min=1;
tau_max=10;
Ts=0.05;
beta=0.5;

try
    % Optimal fit of sin(th) between 0 and pi/2
    syms th a
    f=int((sin(th)-a*th)^2,0,pi/2); % integral of error^2
    df=diff(f,a); % f=convex quadratic function of a,
    alpha=solve(df,a); % find point a where df/da=0
    alpha=double(alpha);
catch
    % No symbolic toolbox installed
    alpha = 24/pi^3;
end
gamma = alpha*pi;


figure(1)
clf
th1=-3/2*pi:pi/16:-pi/2;
th2=-pi/2:pi/16:pi/2;
th3=pi/2:pi/16:3/2*pi;
plot([th1,th2,th3],sin([th1,th2,th3]));hold on
plot(th1,-alpha*th1-gamma,'r');
plot(th2,alpha*th2,'r');
plot(th3,-alpha*th3+gamma,'r');
hold off
grid

Ac=[0 1;g/len*alpha,-beta/len^2/mass]; % [th,thdot]
Bc=[0 0;g/len,1/len^2/mass];     % [s,u]
[A,B]=c2d(Ac,Bc,Ts);
a11=A(1,1);a12=A(1,2);a21=A(2,1);a22=A(2,2);
b11=B(1,1);b12=B(1,2);b21=B(2,1);b22=B(2,2);

S=mld('pendulum',Ts);

% Open loop simulation
u0=2;
ustep=200;
Ntot=400;
U=[u0*ones(ustep,1);zeros(Ntot-ustep,1)];
x0=[-pi/2;0];
[X,T,D,Z,Y]=sim(S,x0,U);

% Validation against NL model
nlmodel = @(t,x) [x(2);g/len*sin(x(1))-beta/len^2/mass*x(2)+u0*(t<ustep*Ts)/len^2/mass];
[t,x]=ode45(nlmodel,[0 Ntot]*Ts,x0);

figure(2)
clf
plot(T,Y,t,x(:,1),'r');
grid

clear Q refs limits
refs.y=1;
refs.u=1;
Q.y=1;
Q.u=.01;
Q.rho=Inf; % Hard constraints
Q.norm=Inf;

N=5;
limits.umin=-tau_max;
limits.umax=tau_max;
%limits.xmin=[-2*pi;-Inf];
%limits.xmax=[2*pi;Inf];

C=hybcon(S,Q,N,limits,refs);
%C.mipsolver='gurobi';

Tstop=4;
r=struct('y',0,'u',0);
x0=[pi;0];
[X,U,D,Z,T,Y]=sim(C,S,r,x0,Tstop);

figure(3)
clf
subplot(211);
plot(T,Y);
grid
axis([0 Tstop -pi/4 pi])
title('\theta')
subplot(212);
stairs(T,U);
title('input torque')
grid
axis([0 Tstop -tau_max*1.1 tau_max*1.1])

open('pendulum_sim');
sim('pendulum_sim',Tstop);

figure(4)
clf
subplot(211);
plot(y.time,y.signals.values);
grid
axis([0 Tstop -pi/4 pi])
title('\theta')
subplot(212);
stairs(u.time,u.signals.values);
title('input torque')
grid
axis([0 Tstop -tau_max*1.1 tau_max*1.1])
