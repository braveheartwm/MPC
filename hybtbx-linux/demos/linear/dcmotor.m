%DC-motor with elastic shaft

%(C) 2003 by A. Bemporad

%Parameters (MKS)
%------------------------------------------------------------------------------------------
Lshaft=1.0;      %Shaft length
dshaft=0.02;     %Shaft diameter
shaftrho=7850;   %Shaft specific weight (Carbon steel)
G=81500*1e6;     %Modulus of rigidity

tauam=50*1e6;    %Shear strength

Mmotor=100;      %Rotor mass
Rmotor=.1;       %Rotor radius
Jmotor=.5*Mmotor*Rmotor^2; %Rotor axial moment of inertia                      
Bmotor=0.1;      %Rotor viscous friction coefficient (guessed)
R=20;            %Resistance of armature
Kt=10;           %Motor constant

gear=20;         %Gear ratio


Jload=50*Jmotor; %Load NOMINAL moment of inertia
Bload=25;        %Load NOMINAL viscous friction coefficient

Ip=pi/32*dshaft^4;               %Polar momentum of shaft (circular) section
Kth=G*Ip/Lshaft;                 %Torsional rigidity (Torque/angle)
Vshaft=pi*(dshaft^2)/4*Lshaft;   %Shaft volume
Mshaft=shaftrho*Vshaft;          %Shaft mass
Jshaft=Mshaft*.5*(dshaft^2/4);   %Shaft moment of inertia

JM=Jmotor; 
JL=Jload+Jshaft;

%Input/State/Output continuous time form
%------------------------------------------------------------------------------------------
AA=[0             1             0                 0;
    -Kth/JL       -Bload/JL     Kth/(gear*JL)     0;
    0             0             0                 1;
    Kth/(JM*gear) 0             -Kth/(JM*gear^2)  -(Bmotor+Kt^2/R)/JM];
                
BB=[0;0;0;Kt/(R*JM)];

Hyd=[1 0 0 0];
Hvd=[Kth 0 -Kth/gear 0];

Dyd=0;
Dvd=0;

Vmax=tauam*pi*dshaft^3/16; %Maximum admissible torque
Vmin=-Vmax;

% Prepare parameters 

Ts=.1;     %Sampling time
%Tstop=40*Ts;   %Simulation time
Tstop=200*Ts;

sys=ss(AA,BB,[Hyd;Hvd],[Dyd;Dvd]);
[A,B,C,D]=ssdata(sys);
x0=zeros(4,1);
 
% LTI model for optimization
model=c2d(sys,Ts);

clear limits
limits.umin=-220;
limits.umax=220;
limits.dumin=-Inf;
limits.dumax=Inf;
limits.ymin=[-Inf Vmin];
limits.ymax=[Inf Vmax];

cost=struct('S',diag([1000 0]),'T',0.05);
cost.rho=Inf; % hard constraints
%cost.rho=100; % soft constraints

% Define horizons
moves=2;     % number of free control moves
Nu=moves;    % Nu = input horizon    u(0),...,u(Nu-1) 
N=10;        % Optimal control horizon
Ncy=10;      % Output constraints are only checked for one sample step
interval=struct('Nu',Nu,'N',N,'Ncy',Ncy);

% Optimal controller based on on-line optimization (implicit)
Cmotor=lincon(model,'track',cost,interval,limits);

% Observer design
kalman(Cmotor,[],[],1); % Only output #1 is measurable
xhat0=0*x0;

open_system('dcmotorsim.mdl')
sim('dcmotorsim',Tstop)

h=msgbox('Now compute explicit version of the controller');
waitfor(h);
close_system('dcmotorsim');

clear range options
range.xmin=-10*ones(4,1);
range.xmax=10*ones(4,1);
range.umin=limits.umin;
range.umax=limits.umax;
range.refymin=[-10,-0.1];
range.refymax=[10,0.1];

options.join=0;

Cmotorexp=expcon(Cmotor,range,options);
plotsection(Cmotorexp,[1 4 5 6 7],[0 0 0 0 0]);
%axis([-3 3 -3 3])

h=msgbox('Now simulate the closed-loop system');
waitfor(h);
close(gcf)

open_system('dcmotorsimexp.mdl')
sim('dcmotorsimexp',Tstop)
