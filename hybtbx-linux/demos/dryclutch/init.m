% Dry Clutch Engagement

% (C) 2000-2003 by A. Bemporad

we0=95; %Initial engine speed
wv0=0;  %Initial vehicle speed

Ie=0.2;
Iv=0.7753;
be=0.03;
bv=0.03;

k=0.098;
mud=0.4;
R=3*k/(4*mud);

Fnmax=5000;
umin=0;
umax=8000;
q=1000;
r=1;

muk=1;
mus=1.5; % The Mathworks
%mus=1;  % Glielmo-Vasca

%TinNOM=150;
%TlNOM=30;

Ts=.01;
Tstop=1;

Tin0=100;
ttt=(0:Ts:Tstop)';
Tin=[ttt,Tin0*ones(size(ttt))];

% Ramp torque
Tin0dot=250;
Tin=Tin+[zeros(size(ttt)),Tin0dot*ttt];

Tl0=4.8;
Tl=[ttt,Tl0*ones(size(ttt))]; % From Table 2, Glielmo-Vasca


% Glielmo-Vasca LQ Controller:

Fn=[   0        0;  % From Figure 5, Glielmo-Vasca
    .10000     800;
    .20000    1300;
    .30000    1550;
    .40000    1700;
    .50000    1750;
    .60000    1800;
    .70000    1800;
    .80000    1800;
    .90000    1800;
    1.0000    1800];
DUMMY=Fn;


% MPC Prediction Model

% Unlocked model
%
% states = we, we-wv
% inputs = Fn, Tin, Tl
% outputs = we, we-wv

A=[-be/Ie, 0;
    (-be/Ie+bv/Iv), -bv/Iv];

B=[-k/Ie, 1/Ie, 0;
    -(k/Ie+k/Iv),1/Ie,1/Iv];

C=eye(2);
D=zeros(2,3);


% Introduce ramp-disturbances for estimation of Tin
% Introduce step-disturbances for estimation of Tl

% states = we, we-wv, Tin, dot_Tin, Tl
% inputs = Fn, 
% outputs = we, we-wv

A=[A,B(:,2),zeros(2,1),B(:,3);
    0 0 0 1 0;
    zeros(2,5)];
B=[B(:,1);0;0;0];
C=[C,zeros(2,3)];
D=D(:,1);

sys=ss(A,B,C,D);

model=c2d(sys,Ts);
[A,B,C,D]=ssdata(model);

% Constraints

dumin=umin*Ts;
dumax=umax*Ts;
% umax=Inf;
% umin=-Inf;
% ymin=[-Inf,-Inf]'; %[-Inf,0]; %[50,Inf];
% ymax=[Inf,Inf]';
clear limits
limits.dumin=dumin;
limits.dumax=dumax;

sp=[0 0]';    % desired output set-point change from equilibrium

clear interval cost

controller_num=1;
switch controller_num
    case 1
        % Controller #1
        clear cost
        cost.T=1;
        cost.S=diag([0 2]);
        interval.N=10;
        interval.Nu=1;
        interval.Ncy=2;
        interval.Ncu=2;
        
    case 2
        % Controller #2
        cost.T=1;
        cost.S=diag([0 1.5]);
        interval.N=10;
        interval.Nu=2;
        interval.Ncy=2;
        interval.Ncu=2;
    case 3
        % Controller #3
        cost.T=1;
        cost.S=diag([0 1.4]); %.067]);
        interval.N=10; %50;
        interval.Nu=2;
        interval.Ncy=2;
        interval.Ncu=2;
end

cost.rho=Inf;

%Tin0=50;
%Tin0dot=150;
%Tl0=10;

x0=[we0,we0-wv0,Tin0,Tin0dot,Tl0]';
u1=0;

xhat0=[we0,we0-wv0,Tin0,Tin0dot,Tl0]';
u1=0;

C=lincon(model,'track',cost,interval,limits);

% Design Kalman filter
kalman(C,.1,.01);


open_system('dryclutchsim');
sim('dryclutchsim');

plotresults;

h=msgbox('Now compute explicit controller');
waitfor(h);
close(gcf)
close_system('dryclutchsim');

% Now compute explicit controller

clear range options
range.xmax=[2000;2000;2000;2000;2000];
range.xmin=[-4000;-4000;-4000;-4000;-4000];
range.umax=5000;
range.umin=-400;
range.refymin=[-10;-10];
range.refymax=[10;10];

options.uniteeps=1e-5;
E=expcon(C,range,options);

% Write solution to latex file
texfile='dry_clutch';
latex(E,texfile);

Tin0=110;
Tin0dot=250;
Tl0=4.8;
[h,E1]=plotsection(E,[3 4 5 6 7 8],[Tin0,Tin0dot,Tl0,0,0,0],[],0);

% Now E1 is defined over the state space (we, we-vv). Change
% the partition to (we,vv)
M=[1 0;1 -1]; % Transformation matrix [we,vv]=M*[we,we-vv]
E1.H=E1.H*inv(M);  % H*[we,we-vv]=H*inv(M)*[we,vv]
plot(E1);
axis([0 500 0 500]);

switch controller_num
    case 1
        u0=[2000]; %[1140]; %900
    case 2
        u0=[2000]; %[1140]; %900
    case 3
        u0=[1300]; %[1140]; %900
end

title(sprintf('Section with Tin=%5.2f, Tindot=%5.2f, Tl=%5.2f, u=%5.2f, r=[0,0]',...
    Tin0,Tin0dot,Tl0,u0))
axis([0 300 0 300]); %axis([0 150 0 50]);
xlabel('\omega_e');
ylabel('\omega_v');


[TT,XX,YY]=sim('dryclutchexpsim');

plotresults;
