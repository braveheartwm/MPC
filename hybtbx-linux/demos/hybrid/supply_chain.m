PA1=4;
PB1=6;
PB2=7;
PC2=3;
xM1=10;
xM2=10;

Ts=1; % Sampling time

S=mld('supply_chain',Ts);

clear Q refs limits
refs.y=[1 2];   % output references (no state, input, zeta references)
Q.y=diag([10 10]);
Q.u=diag([4 4 2 2 1 1 4 4 4 4 10 10]); % Costs for transferring goods
Q.rho=Inf;  % hard constraints
Q.norm=Inf;
N=2;

limits=[];
limits.umin=[zeros(4,1); zeros(8,1)];
limits.umax=[5*ones(4,1); ones(8,1)];
limits.xmin=[0;0;0;0];
limits.xmax=[xM1;xM1;xM2;xM2]; % This is actually redundant, given that x11+x12<=xM1 and x21+x22<=xM2
%limits.ymin=-2;
%limits.ymax=2;

C=hybcon(S,Q,N,limits,refs);
%C.mipsolver='cplexint';
%C.mipsolver='gurobi';

Tstop=50;
x0=[0;0;0;0];
clear r
r.y=[6+2*sin((0:Tstop-1)'/5) 5+3*cos((0:Tstop-1)'/3)];

[XX,UU,DD,ZZ,TT,YY]=sim(C,S,r,x0,Tstop);
subplot(211);
plot(TT,YY,TT,r.y,TT,YY,'*')
grid
axis([0 TT(end) 0 max(max(r.y))])
title('Items sold, demand')
subplot(212);
plot(TT,UU(:,1)+UU(:,2),TT,UU(:,3)+UU(:,4));
axis([0 TT(end) 0 2*max(limits.umax)])
grid
title('Items sold from each inventory')
figure
subplot(211);
plot(TT,1*(UU(:,5)+UU(:,6)),TT,2*(UU(:,7)+UU(:,8)+UU(:,9)+UU(:,10)),TT,3*(UU(:,11)+UU(:,12)));
title('Who is producing ...')
axis([0 TT(end) -.5 3.5])
grid
subplot(212);
plot(TT,XX(:,1)+XX(:,2),TT,XX(:,3)+XX(:,4));
grid
axis([0 TT(end) 0 10])
title('Inventory levels')


if 0,
    N=1;
    C=hybcon(S,Q,N,limits,refs);
    
    % Get the PWA representation of the MLD model
    P=pwa(S);
    
    % Range definition
    clear range;
    range.xmin=limits.xmin-0.1;
    range.xmax=limits.xmax+0.1;
    range.umin=limits.umin-0.1;
    range.umax=limits.umax+0.1;
    
    range.refymin=[0 0]';
    range.refymax=[10 10]';
    
    clear options
    
    % This sets the values of the inputs taud and lambdad.
    options.fixref.u=[1:12];
    options.valueref.u=zeros(12,1);
    
    %options.lpsolver='glpk';
    options.lpsolver='nag';
    options.qpsolver='nag';
    %options.qpsolver='cplex';
    
    E=expcon(C,range,options);
    
    plotsection(E,[1 2 3 4],[0 0 0 0],[],[],[],1);
end