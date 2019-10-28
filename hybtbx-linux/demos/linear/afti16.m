% AFTI-16 2x2 system

% (C) 2003 by Alberto Bemporad
clear variables

% Prepare parameters

Ts=.05;     %Sampling time
Tstop=80*Ts;   %Simulation time

% True plant & true initial state
A=[-.0151 -60.5651 0 -32.174;
     -.0001 -1.3411 .9929 0;
     .00018 43.2541 -.86939 0;
      0      0       1      0];
B=[-2.516 -13.136;
     -.1689 -.2514;
     -17.251 -1.5766;
     0        0];
C=[0 1 0 0;
     0 0 0 1];
D=[0 0;
     0 0];

sys=ss(A,B,C,D);
x0=zeros(4,1);

% prediction model
model=c2d(sys,Ts);

clear limits
limits.umin=-25*[1 1]';
limits.umax=25*[1 1]';
limits.dumin=-Inf*[1 1]';
limits.dumax=Inf*[1 1]';
%limits.ymin=[-.5 -Inf]';
%limits.ymax=[.5 Inf]';

clear cost
cost.S=diag([1 1]); % Output weight
%cost.S=diag([25 1]); % Output weight
cost.T=0.01*eye(2);    % Input increment weight
cost.rho=Inf; % Hard constraints

clear interval
interval.Nu=2;  % input horizon  u(0),...,u(Nu-1)
interval.N=10;  % output horizon   \sum_{k=0}^{Ny-1}
%interval.Ncy=1; % output constraints horizon   k=0,...,Ncy
%interval.Ncu=1; % input constraints horizon    k=0,...,Ncu

Cf16=lincon(model,'track',cost,interval,limits);
%Cf16.qpsolver='gurobi';

u1=[0;0]; %previous input
sp=[0 20];

refs.y=sp;
[X,U,T,Y]=sim(Cf16,model,refs,x0,Tstop,u1);
plot(T,Y,T,ones(size(T'))*sp);

h=msgbox('Now simulate closed-loop system in Simulink');
waitfor(h);
close(gcf);

open_system('afti16sim');
sim('afti16sim',Tstop);


h=msgbox({'Closed-loop system simulated using QP.',...
        'Now compute explicit controller'});
waitfor(h);
close(gcf)

% Note: set interval.Ncy=1 in case you include output constraints

clear range
range.xmax=[1000;1;30;10];
range.xmin=-range.xmax;
range.umax=[26;26];
range.umin=-range.umax;
range.refymax=[10;10];
range.refymin=-range.refymax;

clear options
options.verbose=1;
options.reltol=1e-7;
options.uniteeps=1e-3;   % To by multiplied by tighteps to get tolerance to recognize same gain
%options.qpsolver='nag';    % Use E04NAF
options.qpsolver='qpact';  % Use active set QP
%options.qpsolver='clp';  
%options.lpsolver='glpk';
%options.lpsolver='linprog';

Cf16e=expcon(Cf16,range,options);
plotsection(Cf16e,1:6,[0 0 0 0 0 0]);

h=msgbox('Now simulate closed-loop system');
waitfor(h);
close(gcf);

[X,U,T,Y,I]=sim(Cf16e,model,refs,x0,Tstop,u1);
plot(T,Y,T,ones(size(T))*sp);

h=msgbox('Now simulate closed-loop system in Simulink');
waitfor(h);
close(gcf);

open_system('afti16simexp');
sim('afti16simexp',Tstop);


