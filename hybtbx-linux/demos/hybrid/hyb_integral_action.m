Ts=1;
plant=mld('hyb_integral_action_plant',Ts);
extended_plant=mld('hyb_integral_action_extended',Ts);

clear Q refs limits
refs.y=1;   % output reference
refs.x=3;   % state reference (integral of error signal)
Q.y=1;
Q.x=10;
Q.rho=Inf;  % hard constraints
Q.norm=inf;
N=2;

limits.umin=-2;
limits.umax=2;

HybMPC=hybcon(extended_plant,Q,N,limits,refs);

Tstop=10;
x0=[0;0];
open_system('hyb_integral_action_model');
sim('hyb_integral_action_model',Tstop);