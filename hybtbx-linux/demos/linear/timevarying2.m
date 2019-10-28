% Finite-time optimal control of a time-varying linear system with time-varying limits
%
% This demo shows how the Hybrid Toolbox can handle time-varying linear
% prediction models and limits.

% (C) 2009 by A. Bemporad

clear variables

interval.N=20;
interval.Nu=20;

cost.S=1;
cost.T=1e-2;

lims.umin=0;
lims.umax=3;
ymax=1.5-sin((0:interval.N-1)/5);
for i=1:interval.N,
    lims.ymin=-Inf;
    lims.ymax=ymax(i);
    limits{i}=lims;
end

sys=tf(1,[6 1.5 1]);
Ts=1;
sys=ss(c2d(sys,Ts)); % prediction model

% Create array of model structures
model=cell(interval.N,1);
for i=1:interval.N,
    g=sin(i/2);
    model{i}=sys;
    model{i}.C=sys.C*(1+0.5*g);
end

% Solve finite-time optimal control problem
r=1;
x0=[0;0]; % Initial state
u1=0;     % Input at time t=-1;

C=lincon(model,'track',cost,interval,limits);

[du,Opt]=eval(C,x0,r,u1);
subplot(211)
plot(Opt.t,Opt.y,Opt.t,ymax,Opt.t,r*ones(size(Opt.t)));grid
title('Optimal output trajectory')
subplot(212)
plot(Opt.t,Opt.u);grid
title('Optimal input trajectory')


