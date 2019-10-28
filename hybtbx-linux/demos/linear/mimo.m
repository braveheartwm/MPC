% Example 7.2 from the following reference:
%
% A. Bemporad, M. Morari, V. Dua, and E.N. Pistikopoulos, ``The explicit linear 
% quadratic regulator for constrained systems,'' Automatica, vol. 38, no. 1, 
% pp. 3-20, 2002. 
%
% (C) 2004 by A. Bemporad

clear variables

% Defines the linear model
plant=tf(10,[100 1])*[4 -5;-3 4];
Ts=1; %Sampling time
model=c2d(plant,Ts);

% Define cost function
T=.1*eye(2); % input weight matrix
S=eye(2);    % output weight matrix
cost=struct('S',S,'T',T);
cost.rho=Inf; % hard constraints

% Define constraints
limits=struct('umin',[-1;-1],'umax',[1;1]);

% Define horizons
Nu=1;  % number of free control moves
N=20;  % prediction horizon
interval=struct('N',20,'Nu',Nu);

% Creates linear constrained optimal controller based 
% on quadratic programming on-line optimization
C=lincon(model,'track',cost,interval,limits);

% Convert the controller to explicit piecewise affine form:

% range of parameters over which the solution is determined
xmax=[100;100];
refymax=1;
range=struct('xmin',-xmax,'xmax',xmax,'umin',-1,'umax',1,'refymin',-refymax,...
    'refymax',refymax); 

con=expcon(C,range); % Actual conversion

sp=[0.63 0.79]'; % Desired output set-point change from equilibrium

plotsection(con,[3 4 5 6],[0 0 sp(1) sp(2)]); % Plot partition

h=msgbox('Now simulate closed-loop system');
waitfor(h);
close(gcf)

% Closed-loop simulation
x0=[0 0]';       % Initial state
Tstop=200;       % Simulation time (seconds)

refs=struct('y',sp');
%[X,U,T,Y,I]=sim(con,model,refs,x0,Tstop);
sim(con,model,refs,x0,Tstop);
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
u0=[0;0];
for t=1:T,
    X=[X;x'];
    [Du,reg]=expconmex([x;u0;sp]);
    u=u0+Du;
    y=con.model.C*x+con.model.D*u;
    x=con.model.A*x+con.model.B*u;
    Y=[Y y];
    U=[U u];
    u0=u;
    REG=[REG;reg];
end
figure('name','MEX explicit solution');
subplot(311)
plot(0:T-1,Y);
title('output');
grid
subplot(312)
stairs(0:T-1,U');
title('input');
grid
subplot(313)
stairs(0:T-1,REG);
title('region');
grid
set(gcf,'Position',pos);