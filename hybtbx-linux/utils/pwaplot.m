function h=pwaplot(sol,colors,fighandle,pauseflag,overlap,xlab,ylab,zlab,shaded);
%PWAPLOT Plot polyhedral partitions (1D, 2D or 3D)
% 
%  PWAPLOT(sol) plots the polyhedral partition corresponding to the
%  multiparametric solution 'sol'. Only 1D, 2D and 3D plots are
%  supported. If the partition has more parameters, plots can be obtained
%  through PWAPLOTSECTION. 
%
%  In case of 1D partitions, a dummy 2nd parameter
%  is introduced to make the plot 2D.
%
%  PWAPLOT(sol,colors) also specifies a nr-by-3 vector of RGB colors
%
%  PWAPLOT(sol,colors,fighandle) also specifies the figure handle where the partition is
%  plotted. For subplots, use fighandle='xyz', where (x,y) define the number of subplots 
%  and z the subplot number. Example: PWAPLOT(sol,[],'221') plots the partition in subplot(2,2,1) 
%
%  PWAPLOT(sol,colors,fighandle,pauseflag) pause after each plotting 
%  each cell if pauseflag=1  
%
%  PWAPLOT(sol,colors,fighandle,pauseflag,overlap) plots multiple
%  partitions in the same screen if overlap=1
%
%  PWAPLOT(sol,colors,fighandle,pauseflag,overlap,xlab,ylab) also specifies
%  x-label and y-label
%
%  PWAPLOT(sol,colors,fighandle,pauseflag,overlap,xlab,ylab,zlab) also specifies
%  z-label for 3D plots
%
%  PWAPLOT(sol,colors,fighandle,pauseflag,overlap,xlab,ylab,zlab,shaded) draws 
%  the polytopes with FaceAlpha=shaded, or without fill color if shaded=0.
%
%  h=PWAPLOT(sol,...) returns the figure handle used for plotting
%
% (C) 2003-2008 by A. Bemporad

HH=sol.H;
KK=sol.K;
ii1=sol.i1;
ii2=sol.i2;
thmin=sol.thmin;
thmax=sol.thmax;
m=sol.npar;

if sol.npar==1,
    % 1-D partition, create a dummy parameter
    HH=[HH,KK*0];
    thmin=[thmin(:);0];
    thmax=[thmax(:);1];
    m=m+1;
elseif sol.npar~=2 & sol.npar~=3,
    disp('Sorry, only 1D, 2D and 3D plots supported. Try PLOTSECTION.M')
    return
end

if nargin<4|isempty(pauseflag),
    pauseflag=0;
end

if nargin<5|isempty(overlap),
    overlap=0;
end

if nargin<6|isempty(xlab),
    xlab='\theta_1';
end
if nargin<7|isempty(ylab),
    ylab='\theta_2';
end
if nargin<8|isempty(zlab),
    zlab='\theta_3';
end
if nargin<9|isempty(shaded),
    shaded=[];
end
if sol.npar==1,
    ylab='';
end

if nargin<3 | isempty(fighandle),
    hh=findobj('userdata','PLOT');
    if isempty(hh),
        h=figure;
        set(h,'position',[108   131   684   547],'userdata','PLOT');
    else
        h=figure(hh);
        clf;
    end
else
    if isnumeric(fighandle)
        h=figure(fighandle);
    else
        subplot(fighandle)
    end
end

NR=sol.nr; %=length(i1);
NP=length(NR);

if NP>1,
    % Determine subdivision of window
    n11=ceil(sqrt(NP));
    n21=ceil(NP/n11);
    n12=floor(sqrt(NP));
    n22=ceil(NP/n12);
    if n11*n21>=n12*n22,
        n1=n11;
        n2=n21;
    else
        n1=n12;
        n2=n22;
    end
else
    n1=1;
    n2=1;
end

for p=1:NP, % Handle the case of multiple partitions (NR=vector)
    if ~overlap & NP>1,
        subplot(n1,n2,p)
    end
    nr=NR(p);
    
    if nargin<2|isempty(colors),
        thecolors=rand(nr,3);
    else
        if NP>1,
            warning('COLORS ignored when plotting multiple partitions')
            thecolors=rand(nr,3);
        else
            if size(colors,1)~=nr|size(colors,2)~=3,
                error('COLORS has a wrong size')
            end
            thecolors=colors;
        end
    end
    
    legLab = []; % legend labels
    handles = []; % legend handles
    j=0;

    if (NP==1) & ~iscell(HH),
        H=HH;
        K=KK;
        i1=ii1;
        i2=ii2;
    else
        H=HH{p};
        K=KK{p};
        i1=ii1{p};
        i2=ii2{p};
    end
    
    lpsolver=3; %glpk
    %    if ~exist('glpkmex.dll'),
    %    	lpsolver=1;
    % 	end
    if isempty(H), % Handle the unconstrained case
        Hii=[eye(m);-eye(m)];
        Kii=[thmax;-thmin];
    end
        
    for i=1:nr % for all regions
        col=thecolors(i,:);
        
        removetol=1e-3;
        if isempty(H), % Handle the unconstrained case
            isemptypoly=0;    
        else
            [Hii,Kii,isemptypoly]=polyreduce([H(i1(i):i2(i),:);eye(m);-eye(m)],[K(i1(i):i2(i));thmax;-thmin],lpsolver,removetol);
        end
        if ~isemptypoly,
            if m==2,
                [aux1,handle]=polyplot(Hii,Kii,col,shaded);
            elseif m==3,
                facethandles=polyplot3d(Hii,Kii,col,shaded);
                handle=facethandles(1);
            end
            
            hold on
            drawnow
            j=j+1;
            legLab{j} = sprintf('%d',i);
            handles(j)=handle;
            if pauseflag, 
                pause; 
            end
        end
    end
    if ~isempty(legLab) & NP<=4 & ~overlap,
        [LEGH,OBJH,OUTH,OUTM]=legend(handles,legLab);
        % Look for FaceAlpha
        flag=1;i=0;FaceAlpha=1;
        while flag & i<10, % i<10 to prevent infinite loops
            i=i+1;
            obj=OUTH(i);
            if strcmp(get(obj,'Type'),'patch'),
                FaceAlpha=get(obj,'FaceAlpha');
                flag=0;
            end
        end
        for i=1:length(OBJH),
            obj=OBJH(i);
            if strcmp(get(obj,'Type'),'patch'),
                set(obj,'FaceAlpha',FaceAlpha);
            end
        end
    end
    
    xlabel(xlab);
    ylabel(ylab);
    if m==3,
        zlabel(zlab);
    end
    if ~overlap,
        thetitle='Polyhedral partition';
        if NP>1,
            thetitle=sprintf('%s #%d',thetitle,p);
        end
        thetitle=sprintf('%s - %d regions',thetitle,nr);
        title(thetitle);
    end 
    grid;
end
if overlap,
    thetitle=sprintf('Polyhedral partition - %d regions',sum(NR));
    title(thetitle);
end
if nargout==0,
    clear h
end