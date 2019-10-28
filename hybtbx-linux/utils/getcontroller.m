function [expcon,colors]=getcontroller(mpqpsol,nu,uniteeps,reltol,join,lpsolver,sequence)
% GETCONTROLLER Get explicit optimal controller by computing the union of regions 
% where the first component is the same.
%
% Check if regions are subregions of the same region, and eventually
% unite regions whose union is convex.
%
% uniteeps defines the tolerance used to detect equal rows of matrices.
%
% reltol is added to K so that the partition H*x<=K doesn't have thin holes.
% join=1 try to join regions where gain is the same and union is convex
% sequence=1 keep entire optimal sequence
%
% Reduces as long as the first Nu components of the solution are the same.
% The fields i3,i4,act are removed, as different combinations may be put together.
% Fi,Gi have Nu components, instead of p*Nu
%
% nu=number of inputs
%
% (C) 2003-2009 by A. Bemporad

if nargin<6||isempty(lpsolver),
    lpsolver='glpk';
end
lpsolver=lptype(lpsolver);

if nargin<5||isempty(join),
    join=1;
end
if nargin<4||isempty(reltol),
    reltol=1e-6;
end
if nargin<3||isempty(uniteeps),
    uniteeps=1e-2;
end
if nargin<2||isempty(nu),
    nu=1;
end

if reltol<mpqpsol.flattol,
    % Eliminate regions which have Chebychev radius smaller than reltol, and
    % enlarge the others so that no hole remains.
    
    nr=mpqpsol.nr;
    disp(sprintf('\nAnalyzing region size ...'));
    mpqpsol=reduce(mpqpsol,reltol);
    nr1=mpqpsol.nr;
    
    if nr1<nr,
        disp(sprintf('%d regions eliminated (Chebychev radius < reltol=%7.5f)\n',nr-nr1,reltol));
    end
end

nr=mpqpsol.nr;
F0=mpqpsol.F;
G0=mpqpsol.G;
H=mpqpsol.H;
K=mpqpsol.K;
i1=mpqpsol.i1;
i2=mpqpsol.i2;
nvar=mpqpsol.nvar;
rCheb=mpqpsol.rCheb;
%cCheb=mpqpsol.cCheb;
unconstr_num=mpqpsol.unconstr_num; % Number of the region of no constraints active

npar=size(H,2);

nu_orig=nu;

if sequence,
    nu=nvar;
    F=F0;
    G=G0;
else
    % Removes extra components from F,G
    F=zeros(nu*nr,npar);
    G=zeros(nu*nr,1);
    for i=1:nr,
        F(nu*(i-1)+1:nu*i,:)=F0(nvar*(i-1)+1:nvar*(i-1)+nu,:);
        G(nu*(i-1)+1:nu*i,:)=G0(nvar*(i-1)+1:nvar*(i-1)+nu,:);
    end
end
clear F0 G0

if ~isempty(H), % This may happen if the controller is unconstrained
    P=struct('H',[],'K',[],'FG',[]);
    for i=1:nr,
        P(i)=struct('H',H(i1(i):i2(i),:),'K',K(i1(i):i2(i),:),...
            'FG',[F(nu*(i-1)+1:nu*i,:) G(nu*(i-1)+1:nu*i,:)]);
    end
end

if join && nr>1,
    % Convert solution to array of structures
    
    thmax=mpqpsol.thmax;
    thmin=mpqpsol.thmin;
    
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
            j=i;
            
            while j<=nr-1,
                j=j+1;
                
                % Check for equivalence of the first Nu components of the solution
                if norm(P(i).FG-P(j).FG,'inf')<=uniteeps,
                    
                    [H,K,how]=polyunion(P(i).H,P(i).K,P(j).H,P(j).K,1,uniteeps,1,lpsolver);
                    if strcmp(how,'ok'),
                        fprintf(' regions %d and %d joined !\n',i,j);
                        P(i).H=H;
                        P(i).K=K;
                        removed=1;
                        % Delete regions #i and #j and substitute the union.
                        % Note that certainly the union has number of facets <= of the sum
                        % of facets of the original polyhedra
                        
                        % Compute the Chebichev center x and radius r of the largest Euclidean ball
                        % contained in the region. Note that r indicates how 'flat' is P (r<0 if P is empty).
                        
                        [qC,nC]=size(H);
                        xlam0=zeros(nC+1,1);% Initial guess
                        ECheb=zeros(qC,1);
                        for ii=1:qC,
                            ECheb(ii)=norm(H(ii,:));
                        end
                        [xopt,dummy,how]=lpsol(-[zeros(nC,1);1],[H,ECheb;eye(nC),ones(nC,1);...
                            -eye(nC),ones(nC,1)],[K;thmax;-thmin],[],[],xlam0);
                        
                        rCheb(i)=xopt(nC+1);
                        %aux=xopt(1:nC);
                        %cCheb(i,:)=aux(:)';
                        
                        % Delete regions #j
                        P(j)=[];
                        rCheb(j)=[];
                        nr=nr-1;
                        
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
end

if nr>1,
    rCheb0=rCheb(1:nr,:);
    %cCheb0=cCheb(1:nr,1:npar);
    
    % Order regions by Chebischev radius, but puts unconstrained region first.
    % (actually, here one should recompute the Chebiscev radii and centers
    % by intersecting the region with the box thmin<=th<=thmax. We don't do it
    % to avoid solving one LP per region again)
    
    [rCheb,isort]=sort(rCheb0);
    isort=isort(end:-1:1)'; % Sort by descending order
    if ~isempty(unconstr_num),
        iunc=find(isort==unconstr_num);
    else
        iunc=0;
    end
    isort=[unconstr_num,isort(1:iunc-1),isort(iunc+1:end)]; % Put unconstr_num first, if any
    
    rCheb=rCheb0(isort)'; clear rCheb0
    %cCheb=cCheb0(isort,:); clear cCheb0
    
    i1n=0;
    i2n=0;
    for i=1:nr,
        j=isort(i);
        i1n=i2n+1;
        i2n=i1n+size(P(j).K,1)-1;
        i1(i)=i1n;
        i2(i)=i2n;
        H(i1n:i2n,:)=P(j).H;
        K(i1n:i2n,:)=P(j).K;
        F(nu*(i-1)+1:nu*i,:)=P(j).FG(:,1:npar);
        G(nu*(i-1)+1:nu*i,:)=P(j).FG(:,npar+1);
    end
    
    clear P
    
    H=H(1:i2n,:);
    K=K(1:i2n,:);
    i1=i1(1:nr,:);
    i2=i2(1:nr,:);
    F=F(1:nr*nu,:);
    G=G(1:nr*nu,:);
    
    
    % For on-line implementation, one must slightly relax H*x<=K into H*x<=K+reltol,
    % because otherwise thin 'holes' due to numerical precision may appear.
    
    K=K+reltol;
    
    % ALTERNATIVE: relax by reltol by 'moving' each facet by reltol
    %for i=1:nr,
    %   for j=i1(i):i2(i),
    %      K(j,:)=K(j,:)+reltol*norm(H(j,:));
    %   end
    %end
end

expcon=struct('H',H,'K',K,'F',F,'G',G,'i1',i1,'i2',i2,...
    'nr',nr,'thmin',mpqpsol.thmin,'thmax',mpqpsol.thmax,'nu',nu_orig,'rCheb',rCheb,... %'cCheb',cCheb
    'npar',npar,'flattol',reltol); 

% ALTERNATIVE 2: Eliminates regions which have Chebychev radius smaller than reltol, and
% enlarge the others so that no hole remains.

disp(sprintf('\nAnalyzing region size ...'));
expcon=reduce(expcon,reltol);
nr1=expcon.nr;

if nr1<nr,
    disp(sprintf('%d regions eliminated (Chebychev radius < reltol=%7.5f)\n',nr-nr1,reltol));
end

disp(sprintf('-->>Number of regions in the control law: %d\n',nr1));

%% Removes constraints th<=thmax, th>=thmin
%[Hi1,Ki1]=remove_thmax(Hi,Ki,thmax,thmin);

if nargout==2,
    % Assign same colors where the gain is the same
    colors=rand(nr,3); % Later, same color for regions where the gain is the same
    assigned=zeros(nr,1);
    for i=1:nr,
        if ~assigned(i),
            Fi=F(nu*(i-1)+1:nu*i,:);
            Gi=G(nu*(i-1)+1:nu*i,:);
            for j=i+1:nr,
                Fj=F(nu*(j-1)+1:nu*j,:);
                Gj=G(nu*(j-1)+1:nu*j,:);
                if norm([Fi Gi]-[Fj Gj],'inf')<=uniteeps,
                    colors(j,:)=colors(i,:);
                    assigned(j)=1;
                end
            end
        end
    end
end