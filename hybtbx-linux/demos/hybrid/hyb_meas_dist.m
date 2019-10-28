Ts=1;
plant=mld('hyb_meas_dist_plant',Ts);
extended_plant=mld('hyb_meas_dist_extended',Ts);

clear Q refs limits
refs.y=1;   % output reference
Q.y=1;
Q.rho=Inf;  % hard constraints
Q.norm=inf;
N=5;

limits.umin=-2;
limits.umax=2;

HybMPC=hybcon(extended_plant,Q,N,limits,refs);

Tstop=20;
x0=[0;0];
open_system('hyb_meas_dist_model');
sim('hyb_meas_dist_model',Tstop);