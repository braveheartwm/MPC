% Double Integrator Example with binary inputs +/- 1

% (C) 2009 by Alberto Bemporad

clear variables

Ts=1; % Sampling time
model=ss([1 1;0 1],[0;1],[0 1],0,Ts);
[A,B,C,D]=ssdata(model);

a11=A(1,1);
a12=A(1,2);
a21=A(2,1);
a22=A(2,2);
b1=B(1);
b2=B(2);
c1=C(1);
c2=C(2);

S=mld('binary_inputs',Ts);

clear Q refs limits r
refs.y=1;   % output references (no state, zeta references)
refs.u=1;
Q.y=1;
Q.u=.1;
Q.rho=Inf;  % hard constraints
Q.norm=Inf;
N=2;

limits.ymin=-2; % Lower bound on x2

C=hybcon(S,Q,N,limits,refs);

Tstop=100;
x0=[0;0];
r.y=5*sin((0:99)'/5);
r.u=0*r.y;

open_system('binary_inputs_model');
sim('binary_inputs_model',Tstop);

