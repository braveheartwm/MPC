% (C) 2003 by Alberto Bemporad, Siena, October 29, 2003

% Use HYSDEL to convert to MLD form

Ts=0.5; % Sampling time
S=mld('cruisecontrolmodel',Ts);

% Open-loop simulation using the one-step simulator generated by HYSDEL

Tstop=100; % Simulation time (seconds)
Tsteps=ceil(Tstop/Ts); % Number of simulation steps
time=(0:Tsteps-1)*Ts;

load cruisecontroldata  % get input trajectory U
U=U(1:Tsteps,:);
x0=[0;1/3.6]; % initial position and speed

xt=x0;
X=[];
Z=[];
for t=0:Tsteps-1,
   X=[X;xt'];
   ut=U(t+1,:);
   [xt,dt,zt,yt]=cruisecontrolsim(xt,ut);
   Z=[Z;zt'];
end

cruisecontrolplot('Open-Loop Simulation',X,U,Z,time);



% Optimal control using on-line MILP

% Build up optimization problem
% min |v(t+1)-vd| + rhow*|w-wd| + rhoT*|T-Td|

rhow=.01;  % Weight on engine speed w
rhoT=.01;  % Weight on engine torque T

nx=S.nx; % Number of states
nz=S.nz; % Number of auxiliary z-variables
nu=S.nu; % Number of inputs

clear Q refs

wpos=getvar(S,'w'); % Where is variable 'w' located in the z-vector ?
refs.z=wpos;
Q.z=rhow;

vpos=getvar(S,'speed'); % Where is variable 'v' located in the x-vector ?
refs.x=vpos;
Q.x=1;

Tpos=getvar(S,'torque'); % Where is variable 'torque' located in the u-vector ?
refs.u=Tpos;
Q.u=rhoT;

N=1; % Optimal control horizon
limits=[];
Q.norm=Inf; % Infinity-norm
%Q.norm=2; % quadratic-norm

C=hybcon(S,Q,N,limits,refs);
%c.mipsolver='cplex'

% Closed-loop MPC control using SIM

% Define reference vectors
XR=[];
ZR=[];
UR=[];
for t=0:Tsteps-1,
    
    if t*Ts<30,
        vd=120/3.6; % Desired velocity (m/s)
    elseif t*Ts>=30 && t*Ts<=75,
        vd=50/3.6;  % Desired velocity (m/s)
    else
        vd=100/3.6; % Desired velocity (m/s)
    end
    wd=2000*2*pi/60; % Desired engine speed
    Td=120;          % Desired engine torque
    
    XR=[XR;vd'];
    ZR=[ZR;wd'];
    UR=[UR;Td'];
end

clear r
r.x=XR;
r.z=ZR;
r.u=UR;

[X,U,D,Z,T]=sim(C,S,r,x0,Tstop);
figure
cruisecontrolplot('Closed-loop MPC simulation',X,U,Z,T,XR);