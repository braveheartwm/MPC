% Use HYSDEL to convert to MLD form

init

Ts=0.5; % Sampling time
S=mld('cruisecontrolmodelexp',Ts);

nx=S.nx; % Number of states

clear Q refs
Q.x=1;
refs.x=1;
refs.y=[];
refs.u=[];
refs.z=[];
N=1; % Optimal control horizon
limits=[];

C=hybcon(S,Q,N,limits,refs);

r.u=[];
r.z=[];
x0=x0(2); % Speed only
[X,U,D,Z,T,Y]=sim(C,S,r,x0,Tstop);
X=[cumsum(X),X];
figure(1);clf
cruisecontrolplot('Closed-loop MPC simulation',X,U,Z,T,XR);


clear range options
range.xmin=-15;    % Set of velocities where the mp-problem is solved
range.xmax=62;    
range.refxmin=0; % Set of state references where the mp-problem is solved
range.refxmax=62;    

options.verbose=0;
options.lpsolver='glpk'; %   uses GLPKMEX.DLL 
options.uniteeps=1e-6;   
options.flattol=1e-4;
options.waitbar=1;
C.pwa=pwa(S);
E=expcon(C,range,options);
%load cruisecontrolexplicit
plot(E);
set(gcf,'Name','Explicit Controller');


Tstop=100; % Simulation time (seconds)
Tsteps=ceil(Tstop/Ts); % Number of simulation steps

% Define reference vectors
XR=[];
for t=0:Tsteps-1,
    
    if t*Ts<30,
        vd=120/3.6; % Desired velocity (m/s)
    elseif t*Ts>=30 & t*Ts<=75,
        vd=50/3.6;  % Desired velocity (m/s)
    else
        vd=100/3.6; % Desired velocity (m/s)
    end
    wd=4000*2*pi/60; % Desired engine speed
    Td=120;          % Desired engine torque
    
    XR=[XR;vd'];
end

clear r
r.x=XR;

Tstop=100; % Simulation time (seconds)
x0=1/3.6;

[X,U,T,Y,I]=sim(E,S,r,x0,Tstop);
Z=zeros(200,S.nz);
X=[cumsum(X),X];
figure(2);clf
cruisecontrolplot('Closed-loop MPC simulation',X,U,Z,T,XR);
