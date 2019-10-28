function [sol1,lpsolved,colors]=joinconvex(sol,type,varindex,uniteeps,lpsolver)
%JOINCONVEX Join polyhedral regions whose union is a convex set
%
% [sol1,lpsolved,colors]=joinconvex(sol,type,varindex,uniteeps,lpsolver)
%
% type='cost':      join where cost function is the same
% type='optimizer': join where the entries of the optimizer function specified in varindex are the same
%
% varindex: indices of variables that must be taken into account for
%           comparison when type = 'optimizer'. The other variables will be
%           eliminated from the final solution
%
% See also EXPCON/PRIVATE/GETCONTROLLER

% (C) 2003 by A. Bemporad

if nargin<5|isempty(lpsolver),
   lpsolver=3; % GLPK
end
if nargin<4|isempty(uniteeps),
   uniteeps=1e-4;
end
if nargin<3|isempty(varindex),
   varindex=(1:sol.nvar)';
end
if nargin<2|isempty(type),
   type='cost'; % Compare optimal function rather than the optimizer function
end

nvar=sol.nvar;

if nargin<3|isempty(nargin),
   varindex=(1:nvar)';
   nu=nvar;    
else
   nu=length(varindex);
end

lpsolved=0;
nr=sol.nr;
colors=rand(nr,3); % Later, same color for regions where the function is the same

F0=sol.F;
G0=sol.G;
H=sol.H;
K=sol.K;
i1=sol.i1;
i2=sol.i2;
npar=sol.npar;
rCheb=sol.rCheb;
%cCheb=sol.cCheb;

cost=strcmp(type,'cost');
if cost,
   if ~isfield(sol,'f'),
      c=sol.c;
      % Removes extra components from F,G
      f=zeros(nr,npar);
      g=zeros(nr,1);
      for i=1:nr,
         f(i,:)=c'*F0(nvar*(i-1)+1:nvar*i,:);
         g(i,:)=c'*G0(nvar*(i-1)+1:nvar*i,:);
      end
      clear F0 G0
   else
      f=sol.f;
      g=sol.g;
   end
end

fprintf('Trying to join regions ...\n\n');
removed=1;
while removed % While regions keep to be joined
   removed=0; % Assume no region will be joined
   
   i=1;
   while i<=nr,
      fprintf('%5d/%5d ...',i,nr);
      if i/5==round(i/5),
         fprintf('\n');
      end
      if cost,
         fi=f(i,:);
         gi=g(i,:);
      else
         fi=F0(nvar*(i-1)+varindex,:);
         gi=G0(nvar*(i-1)+varindex,:);
      end
      Hi=H(i1(i):i2(i),:);
      Ki=K(i1(i):i2(i),:);
      j=i;
      
      while j<=nr-1,
         j=j+1;
         
         if cost,
            fj=f(j,:);
            gj=g(j,:);
         else            
            fj=F0(nvar*(j-1)+varindex,:);
            gj=G0(nvar*(j-1)+varindex,:);
         end    
         % Check for equivalence of the first Nu components of the solution
         if norm([fi gi]-[fj gj],'inf')<=uniteeps,
            
            
            Hj=H(i1(j):i2(j),:);
            Kj=K(i1(j):i2(j),:);
            
            [Hinew,Kinew,how]=polyunion(Hi,Ki,Hj,Kj,1,uniteeps,1,lpsolver);
            if strcmp(how,'ok'),
               fprintf(' regions %d and %d joined !\n',i,j);
               
               Hi=Hinew;
               Ki=Kinew;
               removed=1;
               % Delete regions #i and #j and substitute the union.
               % Note that certainly the union has number of facets <= of the sum
               % of facets of the original polyhedra
               
               % Delete regions #j
               H(i1(j):i2(j),:)=[];
               K(i1(j):i2(j),:)=[];
               di=size(Hj,1);
               i1(j+1:nr)=i1(j+1:nr)-di;
               i2(j+1:nr)=i2(j+1:nr)-di;
               
               if cost,
                  f(j,:)=[];
                  g(j,:)=[];
               else
                  F0(nvar*(j-1)+1:nvar*j,:)=[];
                  G0(nvar*(j-1)+1:nvar*j,:)=[];
               end
               nr=nr-1;
               i1(j)=[];
               i2(j)=[];
               rCheb(j)=[];
               %cCheb(j,:)=[];
               colors(j,:)=[];
               
               % Replace regions #i with the new one
               
               if i>1,
                  H1=[H(1:i2(i-1),:);
                     Hi];
                  K1=[K(1:i2(i-1),:);
                     Ki];
               else
                  H1=Hi;
                  K1=Ki;
               end
               
               if i<length(i1),
                  H=[H1;H(i1(i+1):end,:)];
               else
                  H=H1;
               end
               if i<length(i1),
                  K=[K1;K(i1(i+1):end,:)];
               else
                  K=K1;
               end
               [qC,nC]=size(Hi);
               di=qC+i1(i)-i2(i)-1; % difference of number of rows between previous Hi,Ki and new one
               i2(i:nr)=i2(i:nr)+di;
               i1(i+1:nr)=i1(i+1:nr)+di;
               
               % Compute the Chebichev center x and radius r of the largest Euclidean ball
               % contained in the region. Note that r indicates how 'flat' is P (r<0 if P is empty).
               
               xlam0=zeros(nC+1,1);% Initial guess
               ECheb=zeros(qC,1);
               for h=1:qC,
                  ECheb(h)=norm(Hi(h,:));
               end
               
               %[xopt,dummy,how]=lpsolve(-[zeros(n,1);1],[crA,ECheb],crb,xlam0,lpsolver);
               [xopt,dummy,how]=lpsol(-[zeros(nC,1);1],[Hi,ECheb],Ki,[],[],xlam0);
               lpsolved=lpsolved+1;
               
               rCheb(i)=xopt(nC+1);
               %aux=xopt(1:nC);
               %cCheb(i,:)=aux(:)';
               
            else
               colors(j,:)=colors(i,:);
            end
         end
      end
      i=i+1;
      %fprintf('\n');
   end
   if removed,
      fprintf('\n\n Repeat pair detection\n\n');
   end
end

% Clean up i1,i2,H,K,F,G
i10=i1(1:nr);
i20=i2(1:nr);
H=H(1:i2(nr),:);
K=K(1:i2(nr),:);
rCheb=rCheb(1:nr,:);
%cCheb0=cCheb(1:nr,1:nth);

sol1=sol;
sol1.H=H;
sol1.K=K;
sol1.i1=i1;
sol1.i2=i2;
sol1.nr=nr;
sol1.rCheb=rCheb;

if cost,
   sol1.g=g(1:nr,:);
   sol1.f=f(1:nr,:);
   sol1.type='pwafun';
   sol1=rmfield(sol1,{'F','G'});
else
   rows=kron(nvar*(0:nr-1),ones(1,nu))+kron(ones(1,nr),varindex(:)');
   sol1.G=G0(rows,:);
   sol1.F=F0(rows,:);
   sol1.type=sol.type;
   sol1.nu=nu;
   sol1.nvar=length(varindex);
   try
      sol1=rmfield(sol1,{'f','g'});
   end
end
