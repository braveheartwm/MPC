% (C) 2003 by Alberto Bemporad, Eindhoven, March 30, 2003
% (C) 2005 by Alberto Bemporad, Siena, May 30, 2005

close all

Ts = 0.3; % sampling time, seconds
beta=0.2;
M=1;
a1 = 2;
a2 = 1;
dist1=1;
dist2=3;
b=.5;
c1=6;
c2=8;
gamma=.5;
Minv=1/M;

S=mld('grab_ball',Ts);

N=10;
T=0:N-1;
U=[sin(T'/3),zeros(N,2)];
x0=[0 0 5 5 0 0]';
[X,T]=sim(S,x0,U);

figure(1)
%subplot(211)
plot(T,X(:,[1,3,4]),'r')
hold on
plot(T,X(:,[1,3,4]),'go')
%stairs(T-.5,D);
%plot(T,X(:,2),'b')
grid
hold off

% Hybrid MPC Control Design
N=5;

umax=50;   % maximum force to cart 
jetmax=10; % maximum jet flow to balls 

clear Q refs limits
refs.x=[1 3 4];
refs.u=[2 3];
Q.x=diag([.5,1,1] );
Q.u=diag([1,1]);
Q.norm=Inf;
limits.umin=[-umax;0;0];           %u>=-umax, u1>=0, u2>=0
limits.umax=[umax;jetmax;Inf];     %u<=umax, u1<=jetmax
            
MPC=hybcon(S,Q,N,limits,refs);

% References
clear r
r.x=[0 0 0];
r.u=[0 0];

% Initial condition
x0=[0 0 5 5 0 0]';

Tstop=15*Ts;
[state,input,D,Z,T,Y]=sim(MPC,S,r,x0,Tstop);

figure(2)
subplot(211)
plot(T,state(:,1),'r');
hold on
plot(T,state(:,1),'ro');
plot(T,state(:,3),'b');
plot(T,state(:,3),'bo');
plot(T,state(:,4),'g');
plot(T,state(:,4),'go');
plot(T,state(:,5),'b');
plot(T,state(:,5),'bo');
plot(T,state(:,6),'g');
plot(T,state(:,6),'go');
%stairs(T-.5,D);
%plot(T,X(:,2),'b')
grid

subplot(212)
plot(T,input(:,1),'r')
hold on
plot(T,input(:,1),'ro')
plot(T,input(:,2),'b')
plot(T,input(:,2),'bo')
plot(T,input(:,3),'g')
plot(T,input(:,3),'go')
grid
hold off

