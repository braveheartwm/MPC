Ts=0.5;
alpha1 = 1; 
alpha2 = 0.5;
k1 = .8;
k2 = .4;
Thot1 = 30;
Tcold1 = 15;
Thot2 = 35;
Tcold2 = 10;
Uc = 2; % air conditioning power flow
Uh = 2; % heater power flow

clc
% Generate the MLD model
S=mld('heatcoolmodel',Ts);

% Generate the equivalent PWA model
P=pwa(S);

% Plot partition (without input to make it 2D)
colors=[.5 1 .5;1 1 .5;.5 1 .5;1 .5 .5;1 1 .5];

Tamb=25;
plotsection(P,struct('u',1),struct('u',Tamb),1,colors);
xlabel('Temperature T_1 (C)')
ylabel('Temperature T_2 (C)')
title(sprintf('Section for T_{amb}=%5.2f C',Tamb));

% Plot full 3D partition
figure
plot(P,colors);
xlabel('Temperature T_1 (C)')
ylabel('Temperature T_2 (C)')
zlabel('Temperature T_{amb} (C)')
title('Equivalent PWA system');
view(-27,36);

x0=[30;20]; % initial state
TT=[0:Ts:40]';
U=10*cos(TT/10)+20;

% Simulation using PWA model
figure
[XX,TT]=sim(P,x0,U,1e-6);
subplot(221)
plot(TT,XX);
title('PWA trajectories')
grid

% Simulation using MLD model
[XXs,TTs]=sim(S,x0,U);
subplot(222)
plot(TTs,XXs);
title('MLD trajectories')
grid
subplot(223)
plot(TT,XX-XXs)
title('Difference')
grid

% Compare results
disp(sprintf('Difference between MLD and PWA simulated trajectories: %g',norm([XX-XXs])))

% Design MPC controller
clear Q refs limits

refs.x=2;   % only state x(2) is weighted
Q.x=1;      % weight on state x(2)
Q.rho=Inf;  % hard constraints
%Q.norm=2;   % use quadratic costs
Q.norm=Inf; % use infinity norm
N=2;

limits.xmin=[25;-Inf];

C=hybcon(S,Q,N,limits,refs);
C.mipsolver='glpk';   % used for MILP
%C.mipsolver='cplex';  % used for MIQP

Tstop=100;
x0=[30;30]; % initial state
clear r
r.x=30+15*sin((0:199)'/5);

% Simulate Hybrid MPC loop using from command line
[XX,UU,DD,ZZ,TT]=sim(C,S,r,x0,Tstop);
figure
subplot(311);
plot(TT,XX(:,2),TT,r.x);
grid
title('Temperature T_2')
subplot(312);
plot(TT,XX(:,1),TT,10*ZZ(:,2));
grid
title('Temperature T_1, air conditioning')
subplot(313);
plot(TT,UU);
grid
title('Temperature T_{amb}')
set(gcf,'position',[360    55   385   623]);

% Same simulation in Simulink (on-line optimization)
open('heatcool6');
sim('heatcool6');

% Explicit controller
Q.norm=Inf;   % Infinity norm
N=2;
C=hybcon(S,Q,N,limits,refs);

clear range options
range.xmin=[-10,-10];
range.xmax=[50,50];

%options.fixref.x=[2];
%options.valueref.x=[40];

range.refxmin=[10]; % Set of state references where the mp-problem is solved
range.refxmax=[50]; 

options.verbose=0;
%options.lpsolver='glpk'; %   uses GLPKMEX.DLL 
options.lpsolver='nag'; %   uses NAG
%options.qpsolver='nag';
options.uniteeps=1e-6;   
options.flattol=1e-4;
options.waitbar=1;
E=expcon(C,range,options);

%plotsection(E,3,30);
plot(E)
xlabel('Temperature T_1');
ylabel('Temperature T_2');
zlabel('Temperature set point');

% Repeat simulation in Simulink (explicit control evaluation)
open('heatcool9');
sim('heatcool9');

% Reachability analysis
N=10;
%S.milpsolver='cplex';
S.milpsolver='glpk';

% Xf=10<=x1,x2<=15
Xf.A=[eye(2);-eye(2)];
Xf.b=[15;15;-10;-10];

% X0=35<=x1,x2<=40
X0.A=[eye(S.nx);-eye(S.nx)];
X0.b=[40;40;-35;-35];

umin=10;
%umin=20;
umax=30;

[flag,x_0,U,xf,X,T]=reach(S,N,Xf,X0,umin,umax);

if flag==1,
    % Add final state in plot
    X=[X;xf'];
    figure
    subplot(211);
    plot(X(:,1),X(:,2),X(:,1),X(:,2),'*');
    ylabel('T_2');
    xlabel('T_1');
    grid
    title('State')

    subplot(212)
    plot(T,U,T,U,'*');
    grid
    title('Input')
    xlabel('time')
    ylabel('T_{amb}')
    set(gcf,'position',[168    74   359   611]);
    
else
    disp(sprintf('\n\nXf is not reachable from X0'));
end
