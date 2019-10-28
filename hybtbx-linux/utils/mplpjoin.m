function mplpsol2=mplpjoin(mplpsol,tol,solver)
% MPLPJOIN: reduce the mplp solution by joining regions where the value function
% has the same linear expression (Claim: such union is always convex) 

%  (C) 2003 by A. Bemporad

if nargin<2,
    tol=1e-6; % two affine functions fx+g, hx+k are equal if |[f g]-[h k]|_\infty<=tol 
end
if nargin<3,
    solver=[]; % Default LP solver 
end

nr=mplpsol.nr; % number of critical regions, and therefore cost functions
F=mplpsol.F;
G=mplpsol.G;
c=mplpsol.c;

m=size(F,2);               % Number of parameters
nvar=mplpsol.nvar;         % Number of variables
C=zeros(nr,m+1);           % Array of affine functions

for i=1:nr,
    % z=c'(F*th+G)
    C(i,:)=[c'*F((i-1)*nvar+1:i*nvar,:),c'*G((i-1)*nvar+1:i*nvar,:)];
end

%     % Plot value function
%     [x,y]=meshgrid(-2.5:.1:2.5,-2.5:.1:2.5);
%     for i=1:size(x,1);
%         for j=1:size(x,2);
%             % Because the value function y=f(th) is convex, it is defined as y=max_i (C(i,:)*[th;1])
%             th=[x(i,j);y(i,j)];            
%             %z(i,j)=max(C*[th;1]);
%             %xx=lpsol(c,mplpsol.A,mplpsol.b+mplpsol.S*th);
%             %[xx,k]=mpc_m(mplpsol,th);
%             %z(i,j)=c'*xx;
%             z(i,j)=max(C*[th;1]);
%         end
%     end
%     contour(x,y,z,30)


% Form clusters
clust={};     % Cell array if clusters
mustkeep=[];  % Vector of first elements of each cluster
nclust=0;
for i=1:nr,
    inclust=0;
    for j=1:nclust,
        % Is C(i,:) already in some cluster ?
        if norm(C(i,:)-C(clust{j}(1),:),'inf')<tol,
            inclust=1;
            clust{j}=[clust{j},i];
        end
    end
    if ~inclust,
        % form a new cluster
        nclust=nclust+1;
        clust{nclust}=i;
        mustkeep(nclust)=i;
    end
end

% Rebuilds the reduced solution
mplpsol2=mplpsol;

mplpsol2.nr=nclust;

H=mplpsol.H;
K=mplpsol.K;
i1=mplpsol.i1;
i2=mplpsol.i2;
rCheb=mplpsol.rCheb;

Ha=[];
Ka=[];
Fa=[];
Ga=[];
i1a=[];
i2a=[];
rCheba=[];

ii1=0;
ii2=0;
ii3=0;
ii4=0;
ii5=0;
for i=1:nclust,
    theclust=clust{i};
    ntheclust=length(theclust);
    if ntheclust==1, % Only one element in cluster
        j=theclust;
        h1=i1(j);
        h2=i2(j);
        HH=H(h1:h2,:);
        KK=K(h1:h2,:);
        rrCheb=rCheb(j);
        FF=F((j-1)*nvar+1:j*nvar,:);
        GG=G((j-1)*nvar+1:j*nvar,:);
        nconstr=h2-h1+1;
    else
        % Compute envelope of clusters
        Hcell={};
        Kcell={};
        for j=1:ntheclust,
            k=theclust(j);
            Hj=H(i1(k):i2(k),:);
            Kj=K(i1(k):i2(k),:);
            Hcell{j}=Hj;
            Kcell{j}=Kj;
        end
        [HH,KK]=polyenvelope(Hcell,Kcell,solver,1e-4);    
        % Recompute Chebychev center 
        
        [qC,nC]=size(HH);
        xlam0=zeros(nC+1,1);% Initial guess
        ECheb=zeros(qC,1);
        for i=1:qC,
            ECheb(i)=norm(HH(i,:));
        end
        
        % Find Chebiscev center and radius, without intersecting with the box thmin<=th<=thmax:
        [xopt,dummy,how]=lpsol(-[zeros(nC,1);1],[HH,ECheb],KK,[],[],xlam0,[],[],solver);
        
        % Does intersect with thmin<=th<=thmax. Regions outside the box are rejected.
        % thmin=mplpsol.thmin;
        % thmax=mplpsol.thmax;
        % [xopt,dummy,how]=lpsol(-[zeros(nC,1);1],...
        %     [HH,ECheb;[eye(nC);-eye(nC)],ones(2*nC,1)],[KK;thmax;-thmin],...
        %     [],[],xlam0,[],[],solver);
        
        rrCheb=xopt(nC+1); %cCheb=xopt(1:nC);
        
        k=theclust(1); % Picks up the gain from the first region in the cluster
        
        FF=F((k-1)*nvar+1:k*nvar,:);
        GG=G((k-1)*nvar+1:k*nvar,:);
        nconstr=qC;
    end
    
    % Save region and optimizer    
    ii5=ii5+1; % region counter for new solution
    ii1=ii1+1;
    ii2=ii2+nconstr;
    Ha(ii1:ii2,:)=HH;
    Ka(ii1:ii2,:)=KK;
    i1a(ii5)=ii1;
    i2a(ii5)=ii2;
    ii1=ii2;
    
    ii3=ii3+1;
    ii4=ii4+nvar;
    Fa(ii3:ii4,:)=FF;
    Ga(ii3:ii4,:)=GG;
    ii3=ii4;
    rCheba(ii5)=rrCheb;
    
end

mplpsol2.H=Ha;
mplpsol2.K=Ka;
mplpsol2.F=Fa;
mplpsol2.G=Ga;
mplpsol2.i1=i1a;
mplpsol2.i2=i2a;
mplpsol2.rCheb=rCheba;
rmfield(mplpsol2,'act');
rmfield(mplpsol2,'i3');
rmfield(mplpsol2,'i4');