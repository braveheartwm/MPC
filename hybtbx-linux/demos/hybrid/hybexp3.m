close all
S=mld('hybrid3');

clear Q refs limits
refs.y=[1 2];
refs.x=[1 2];
refs.u=[1 2];

Q.norm=Inf;
Q.x=[100 0;0 0]; % not used for N=1
Q.xN=[100 0;0 0];
Q.u=1*eye(2);
Q.y=zeros(2,2);
Q.rho=Inf; % Hard constraints
N=1;
limits.umin=[-10;0];
limits.umax=[10;1];
limits.xmin=[-10;0];
limits.xmax=[10;1];
limits.ymin=[-2;0];
limits.ymax=[2;1];

C=hybcon(S,Q,N,limits,refs);

clear refs
x0=[0;0];
Tstop=40;
refs.x=[.5*cos((0:Tstop-1)'/2),zeros(Tstop,1)];
refs.y=[2*refs.x(:,1),zeros(Tstop,1)];
refs.u=[0*ones(Tstop,1),zeros(Tstop,1)];

[x,u,d,z,t,y]=sim(C,S,refs,x0,Tstop);
subplot(211)
plot(t,y,t,refs.y);
title('On-line MILP')

clear range options
range.xmin=[-10;0];    % Set of initial states where the mp-problem is solved
range.xmax=[10;1];    

options.fixref.x=[2];
options.valueref.x=[0];
options.fixref.u=[2];
options.valueref.u=[1];
options.fixref.y=[1 2];
options.valueref.y=[0 0];

range.refxmin=[-10]; % Set of state references where the mp-problem is solved
range.refxmax=[10]; 
range.refumin=[-10]; % Set of input references where the mp-problem is solved
range.refumax=[10];     

options.verbose=0;
options.lpsolver='glpk'; %   uses GLPKMEX.DLL 
options.uniteeps=1e-6;   
options.flattol=1e-4;
options.waitbar=1;
E=expcon(C,range,options);

[x,u,t,y,i]=sim(E,S,refs,x0,Tstop);
subplot(212)
plot(t,y,t,refs.y);
title('Explicit solution')

% % Compare C vs. E
% 
% r=struct('x',[2;0],'u',[-1 0],'y',[.5;1]);
% [xc,xb]=meshgrid(-10:1:10,0:1);
% JC=zeros(size(xc));
% JE=JC;
% P=pwa(S);
% for i=1:size(xc,1);
%     for j=1:size(xc,2);
%         x0=[xc(i,j);xb(i,j)];
%         
%         uc=eval(C,S,r,x0);
%         ue=eval(E,x0);
%         %xc1=update(P,x0,uc);
%         %xe1=update(P,x0,ue);
%         %JC(i,j)=abs(xc1(1));
%         %JE(i,j)=abs(xe1(1));
%         JC(i,j)=uc;
%         JE(i,j)=ue;
%     end
% end
% %mesh(xc,xb,JC);
% norm(JC-JE)
% 
% 
% c1=eval(C,S,r,[1;1]);
% e1=eval(E,[1;1]);
