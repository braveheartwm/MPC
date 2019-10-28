clear variables

% Defines the linear model
A =[1 -1 0;
    0 1 1;
    1.5 0 1];
B = [-1 1;
    0 0;
    0 1];
C=[1 0 0;0 1 0];
D = zeros(2,2);
    
Ts=1;     %Sampling time
model=ss(A,B,C,D,Ts);

% Define cost function
R=.01*eye(2);       % input weight matrix
Q=eye(3);    % state weight matrix
cost=struct('Q',Q,'R',R,'P','lqr');
cost.rho=Inf; % hard constraints

% Define constraints
limits=struct('umin',[-15;-15],'umax',[15;15]);
%limits=[]; % unconstrained

% Define horizons
Nu=1;  % number of free control moves
interval=struct('Nu',Nu);

% Creates linear constrained optimal controller based 
% on quadratic programming on-line optimization
C=lincon(model,'reg',cost,interval,limits);

% Convert the controller to explicit piecewise affine form:

% range of parameters over which the solution is determined
xmax=50*ones(3,1);
range=struct('xmin',-xmax,'xmax',xmax); 

con=expcon(C,range); % Actual conversion
plot(con); % Plot partition
legend off
