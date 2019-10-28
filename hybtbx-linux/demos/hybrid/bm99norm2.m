Ts=1;
milpsolver='glpk';
S=mld('bm99',Ts,milpsolver);

clear Q refs limits
refs.y=[1];
refs.x=[1 2];
refs.u=[1];
Q.y=1e-5;
Q.x=10*eye(2);
Q.xN=10*eye(2);
Q.u=1;
Q.rho=Inf; % Hard constraints
Q.norm=2;

N=2;
limits.umin=-1;
limits.umax=1;
limits.xmin=[-10;-10];
limits.xmax=[10;10];
limits.Sx=[eye(2);-eye(2)];
limits.Tx=1*[1;1;1;1];


C=hybcon(S,Q,N,limits,refs);

clear range options

range.xmin=[-10;-10];    % Set of initial states where the mp-problem is solved
range.xmax=[10;10];    

options.fixref.x=[1 2];
options.valueref.x=[0 0];
options.fixref.u=1;
options.valueref.u=0;
options.fixref.y=1;
options.valueref.y=0;

range.refxmin=[]; % Set of state references where the mp-problem is solved
range.refxmax=[]; 
range.refumin=[]; % Set of input references where the mp-problem is solved
range.refumax=[];     

options.verbose=0;
options.lpsolver='glpk';   %   uses GLPKMEX.DLL 
options.qpsolver='qpact'; 
%options.qpsolver='nag';  % NAG QP solver is much more reliable
options.uniteeps=1e-6;   
options.flattol=1e-4;
options.waitbar=0;

E=expcon(C,range,options);

%plot(E);         % Plot partitions in different subplots
plot(E,[],0,1);  % Plot partitions in the same plot
grid