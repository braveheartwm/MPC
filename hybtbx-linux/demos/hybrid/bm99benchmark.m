Ts=1;
milpsolver='glpk';
S=mld('bm99',Ts,milpsolver);

clear Q refs limits
refs.y=[]; % No output reference
refs.x=[1 2];
refs.u=[1];
Q.x=10*eye(2);
Q.xN=10*eye(2);
Q.u=1;
Q.rho=Inf; % Hard constraints
Q.norm=Inf;

N=2;
limits.umin=-1;
limits.umax=1;
limits.xmin=[-10;-10];
limits.xmax=[10;10];

C=hybcon(S,Q,N,limits,refs);

clear range options

range.xmin=[-10;-10];    % Set of initial states where the mp-problem is solved
range.xmax=[10;10];    

options.fixref.x=[1 2];
options.valueref.x=[0 0];
options.fixref.u=1;
options.valueref.u=0;

range.refxmin=[]; % Set of state references where the mp-problem is solved
range.refxmax=[]; 
range.refumin=[]; % Set of input references where the mp-problem is solved
range.refumax=[];     

options.verbose=0;
options.lpsolver='glpk'; %   uses GLPKMEX.DLL 
options.uniteeps=1e-6;   
options.flattol=1e-4;
options.waitbar=1;

E=expcon(C,range,options);
plot(E)

% % Compare implicit vs. explicit
% axis([-2 2 -2 2]);
% [x,y]=meshgrid(-2:.1:2,-2:.1:2);
% z=zeros(size(x));
% w=zeros(size(x));
% r=[];
% for i=1:size(x,1);
%     for j=1:size(x,2);
%         th=[x(i,j);y(i,j)];
%         uimp=eval(C,S,r,th);
%         z(i,j)=uimp;
%         uexp=eval(E,th); % In case of multiple solutions, uimp and uexp may be different
%         w(i,j)=uexp;
%     end
% end
% contour(x,y,z,50);
% w-z
