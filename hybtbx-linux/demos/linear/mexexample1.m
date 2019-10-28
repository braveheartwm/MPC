clear variables

% Continuous time system
sys=tf(1,[1 2 1]);
% Sampling tine
Ts=0.1;
% Convert model to discrete-time
sysd=c2d(sys,Ts);

% Setup constrained optimal controller

% Define cost function
S=1;
T=.001;
cost=struct('S',S,'T',T);
cost.rho=Inf; % hard constraints

% Define constraints: on acceleration and velocity
limits=struct('umin',-2,'umax',2);
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

% % Plot a 2D section
% plotsection(Cexp,3:9,[0 0 0 0 0 0 0]);
% axis([-2 2 -2 2]);

% Closed-loop simulation

kalman(Cexp); % Design Kalman filter and append it to Cexp

% Write H-file expcon.h
hwrite(Cexp);

% Compile mex file
clear linobsmex
flinmex=which('linobsmex');
i_ext=findstr(flinmex,'.');i_ext=i_ext(end);
flinmex=flinmex(1:i_ext-1); % Remove extension
eval(sprintf('mex %s.c -I. -output %s',flinmex,flinmex));

% Initialize controller
linobsmex([],[],1);

% Initial conditions
x0=zeros(2,1);
%x0=rand(2,1)*.5-.5;
u1=0; % Input at time -1

x=x0;
Y=[];
U=[];
R=[];
REG=[];
X=[];
T=100;

for t=1:T,
    X=[X;x'];
    if t>50,
        r=.5;
    else
        r=1;
    end
    y=Cexp.model.C*x;
    [u,reg]=linobsmex(y,r,0);
    x=Cexp.model.A*x+Cexp.model.B*u;
    Y=[Y;y];
    R=[R;r];
    U=[U;u];
    REG=[REG;reg];
end
subplot(311)
plot(0:T-1,[Y R]);
grid
subplot(312)
stairs(0:T-1,U);
grid
subplot(313)
stairs(0:T-1,REG);
grid
