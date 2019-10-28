S=mld('logicstate');

clear Q refs limits
refs.y=[];
refs.x=[1];
refs.u=[];
Q.x=1;
Q.xN=1;
Q.u=[];
Q.rho=Inf; % Hard constraints
Q.norm=Inf;

N=2;
limits.umin=-10;
limits.umax=10;
limits.xmin=[-10;0];
limits.xmax=[10;1];

C=hybcon(S,Q,N,limits,refs);
%C.mipsolver='cplex';

clear range options
range.xmin=[-10;0];    % Set of initial states where the mp-problem is solved
range.xmax=[10;1];    

options.fixref.x=[1];
options.valueref.x=[0];
options.fixref.u=[];
options.valueref.u=[];

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
plot(E)


% Compare C vs. E

r=struct('x',options.valueref.x,'u',[]);
[xc,xb]=meshgrid(-10:1:10,0:1);
JC=zeros(size(xc));
JE=JC;
P=pwa(S);
for i=1:size(xc,1);
    for j=1:size(xc,2);
        x0=[xc(i,j);xb(i,j)];
        
        uc=eval(C,S,r,x0);
        [ue,region,Useq,cost]=eval(E,x0);
        %xc1=update(P,x0,uc);
        %xe1=update(P,x0,ue);
        %JC(i,j)=abs(xc1(1));
        %JE(i,j)=abs(xe1(1));
        JC(i,j)=uc;
        JE(i,j)=ue;
    end
end
%mesh(xc,xb,JC);
Jdiff=JC-JE;
Jdiff(find(isnan(Jdiff)))=0;
norm(Jdiff)

c1=eval(C,S,r,[1;1])
e1=eval(E,[1;1])
