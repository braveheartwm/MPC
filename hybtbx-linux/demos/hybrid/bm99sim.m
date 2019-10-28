Ts=1;
S=mld('bm99',Ts);
 
% Open-loop simulation
% [X,T,D]=sim(S,[1 1],zeros(20,1));
% subplot(221)
% plot(X(:,1),X(:,2),'-',X(:,1),X(:,2),'*','LineWidth',2);
% xlabel('x-space')
% grid
% subplot(222)
% stairs(T,(1-D)*2*pi/3-pi/3,'LineWidth',2);
% grid
% xlabel('time');
% title('\alpha');


clear Q refs limits r
refs.y=1;   % output references (no state, input, zeta references)
Q.y=1;
Q.rho=Inf;  % hard constraints
Q.norm=Inf;
%Q.norm=2;
N=2;

limits.umin=-1;
limits.umax=1;
limits.xmin=[-10;-10];
limits.xmax=[10;10];
%limits.ymin=-2;
%limits.ymax=2;


C=hybcon(S,Q,N,limits,refs);

if Q.norm==2
    C.mipsolver='gurobi';
end

Tstop=100;
x0=[0;0];
r.y=sin((0:99)'/5);

[XX,UU,DD,ZZ,TT,YY]=sim(C,S,r,x0,Tstop);
subplot(211);
plot(TT,YY,TT,r.y);
grid
subplot(212);
plot(TT,UU);
grid

h=msgbox('Now simulate the closed-loop system in Simulink');
waitfor(h);
close(gcf)

open_system('bm99mld');
sim('bm99mld',Tstop);

h=msgbox('Now convert the MLD system to PWA and simulate it again');
waitfor(h);
close_system('bm99mld');

P=pwa(S);
open_system('bm99pwa');
sim('bm99pwa',Tstop);

h=questdlg('Compute the explicit form of the hybrid controller ?','No','Yes');
close_system('bm99pwa');

if strcmp(h,'No'),
    return
end

clear range options
range.xmin=[-10;-10];    % Set of initial states where the mp-problem is solved
range.xmax=[10;10];    
range.refymin=-1;        % Set of ouput references where the mp-problem is solved
range.refymax=1;     

options.verbose=0;
options.lpsolver='glpk'; %   uses GLPKMEX.DLL 
options.uniteeps=1e-6;   
options.flattol=1e-4;
options.waitbar=1;
E=expcon(C,range,options);
plotsection(E,3,0);

Tstop=100;
P=pwa(S);
x0=[0;0];

h=msgbox('Now simulate closed-loop system with explicit controller');
waitfor(h);
close(gcf);

open_system('bm99exp');
sim('bm99exp',Tstop);