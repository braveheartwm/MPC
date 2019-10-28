% Create MLD model by processing the HYSDEL description
S=mld('hybrid4');

% % Convert the MLD model to PWA
% clear options
% options.verbose=0;
% options.solver='glpk'; %   uses GLPKMEX.DLL 
% options.bounds=1;      %   add bounds -xmax<=x<=xmax, -umax<=u<=umax in the polyhedral
% %     cell definition (=0 don't add)
% options.tighteps=1e-6; %   Tolerance which decides if two dynamics (A,B,f) are equal (default:1e-6)
% P=pwa(S,10,1,options);

clear Q refs limits
refs.y=[];
refs.x=[1 2];
refs.u=[1 2];
Q.x=eye(2);
Q.u=0*eye(2);
Q.rho=Inf; % Hard constraints
Q.norm=Inf;
N=2;
limits=[];

C=hybcon(S,Q,N,limits,refs);
%C.mipsolver='cplex';

clear range options
range.xmin=[-5;-5];    % Set of initial states where the mp-problem is solved
range.xmax=[5;5];    

options.fixref.x=[1 2];
options.valueref.x=[0 0];
options.fixref.u=[1 2];   % Also fix binary input u(2)=1
options.valueref.u=[0 1];

range.refxmin=[]; % All state refs were fixed
range.refxmax=[]; 
range.umin=[];    % All input refs were fixed
range.umax=[];     

options.verbose=1;
options.lpsolver='glpk'; %   uses GLPKMEX.DLL 
%options.qpsolver='nag';
options.uniteeps=1e-6;   
options.flattol=1e-4;
options.waitbar=1;
E=expcon(C,range,options);
plot(E)
%hwrite(E)

% Compare explicit and implicit solutions
disp('Comparing explicit and implicit controllers ...');

axis([-1 1 -1 1]);
[x,y]=meshgrid(-1:.1:1,-1:.1:1);
z=zeros(size(x));
w=zeros(size(x));
r=options.valueref;
for i=1:size(x,1);
    for j=1:size(x,2);
        th=[x(i,j);y(i,j)];
        uimp=eval(C,S,r,th);
        z(i,j)=uimp(1);
        uexp=eval(E,th); % In case of multiple solutions, xopt1 may be diff. from xopt2
        w(i,j)=uexp(1);
    end
end
norm(w-z)
figure
subplot(121)
mesh(x,y,z);
axis([-1 1 -1 1 -2 2]);
subplot(122)
mesh(x,y,w);
axis([-1 1 -1 1 -2 2]);
set(gcf,'Position',[33   225   915   340]);
