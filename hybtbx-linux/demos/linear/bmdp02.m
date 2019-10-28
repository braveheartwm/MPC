% Example 7.1 from the following reference:
%
% A. Bemporad, M. Morari, V. Dua, and E.N. Pistikopoulos, ``The explicit linear 
% quadratic regulator for constrained systems,'' Automatica, vol. 38, no. 1, 
% pp. 3-20, 2002. 
%
% (C) 2003 by A. Bemporad

clear variables

% Defines the linear model
A=[0.7326   -0.0861;
   0.1722    0.9909];
B=[0.0609;0.0064];
C=eye(size(A));
D=zeros(size(B));
Ts=0.1;     %Sampling time
model=ss(A,B,C,D,Ts);

% Define cost function
R=.01;       % input weight matrix
Q=eye(2);    % state weight matrix
cost=struct('Q',Q,'R',R,'P','lyap');
cost.rho=Inf; % hard constraints

% Define constraints
limits=struct('umin',-2,'umax',2,'ymin',[-0.5;-0.5]);
%limits=[]; % unconstrained

% Define horizons
Nu=2;  % number of free control moves
interval=struct('Nu',Nu);

% Creates linear constrained optimal controller based 
% on quadratic programming on-line optimization
C=lincon(model,'reg',cost,interval,limits);

% Convert the controller to explicit piecewise affine form:

% range of parameters over which the solution is determined
xmax=1.5*ones(size(B));
range=struct('xmin',-xmax,'xmax',xmax); 

con=expcon(C,range); % Actual conversion
plot(con); % Plot partition

h=msgbox('Now simulate closed-loop system');
waitfor(h);
close(gcf)

% Closed-loop simulation
x0=[1 1]'; % Initial state
Tstop=4;   % Simulation time (seconds)

%[X,U,T,Y,I]=sim(con,model,[],x0,Tstop);
sim(con,model,[],x0,Tstop);
pos=get(gcf,'Position');

h=msgbox('Now convert the explicit controller to a MEX file and simulate it');
waitfor(h);
close(gcf)


% Write H-file expcon.h
hwrite(con);

% Compile mex file
clear expconmex
filetolocate='mpqp.p';
utildir=which(filetolocate);utildir=utildir(1:end-length(filetolocate));
flinmex=[utildir 'expconmex'];
eval(sprintf('mex %s.c -I. -output %s',flinmex,flinmex));

x=x0;
Y=[];
U=[];
R=[];
REG=[];
X=[];
T=Tstop/Ts;

for t=1:T,
    X=[X;x'];
    [u,reg]=expconmex(x);
    y=con.model.C*x+con.model.D*u;
    x=con.model.A*x+con.model.B*u;
    Y=[Y y];
    U=[U;u];
    REG=[REG;reg];
end
figure('name','MEX explicit solution');
subplot(311)
plot(0:T-1,Y);
title('output');
grid
subplot(312)
stairs(0:T-1,U);
title('input');
grid
subplot(313)
stairs(0:T-1,REG);
title('region');
grid
set(gcf,'Position',pos);