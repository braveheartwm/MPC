function h=plot(P,colors,shaded,az,el);
% PLOT Plot PWA systems (only systems with 2 states) 

% (C) 2003-2006 by A. Bemporad

if nargin<1,
    error('pwa:plot:none','No PWA object supplied.');
end
if ~isa(P,'pwa'),
    error('pwa:plot:obj','Invalid PWA object');
end

nur=P.nur;
nxr=P.nxr;
nub=P.nub;
nxb=P.nxb;
nu=P.nu;
nx=P.nx;


if (nur+nxr)~=2 & (nur+nxr)~=3,
    disp('Sorry, only PWA systems with at most 2 or 3 continuous variables (states/inputs) are supported.')
    return
end

if nargin<2|isempty(colors),
    % to differentiate constraints cycle through the available colors
    %colors='ymcrgbk'; % even white is not Ok, it clash with the background
    
    %Color maps.
    %    hsv        - Hue-saturation-value color map.
    %    hot        - Black-red-yellow-white color map.
    %    gray       - Linear gray-scale color map.
    %    bone       - Gray-scale with tinge of blue color map.
    %    copper     - Linear copper-tone color map.
    %    pink       - Pastel shades of pink color map.
    %    white      - All white color map.
    %    flag       - Alternating red, white, blue, and black color map.
    %    lines      - Color map with the line colors.
    %    colorcube  - Enhanced color-cube color map.
    %    vga        - Windows colormap for 16 colors.
    %    jet        - Variant of HSV.
    %    prism      - Prism color map.
    %    cool       - Shades of cyan and magenta color map.
    %    autumn     - Shades of red and yellow color map.
    %    spring     - Shades of magenta and yellow color map.
    %    winter     - Shades of blue and green color map.
    %    summer     - Shades of green and yellow color map.
    
    auxcolors=hsv;
    for i=1:P.nr,
        jj=mod(i*7,size(auxcolors,1))+1;
        colors(i,:)=auxcolors(jj,:);
    end
else
    if size(colors,1)~=P.nr|size(colors,2)~=3,
        error('COLORS has wrong size')
    end
end

if nargin<3,
    shaded=[];
end
if nargin<4,
    az=[];
end
if nargin<5,
    el=[];
end

clf
hold on
if ~(isempty(az)&isempty(el)),
    view(az,el);
else
    if (nur+nxr)==3,
        view(-19,72);
    end
end
legLab = []; % legend labels
handles = []; % legend handles

% % Get number of different combinations belonging to the same dynamics
% nn=0;
% for i=1:P.nr % for all regions
%     aux=size(P.logic{i},2);
%     if aux>nn,
%         nn=aux;
%     end
% end
% nn=max(nn,nub+nxb);
% if nn>1,
%     view(-37.5,30);
% end

for i=1:P.nr % for all regions
    col=colors(i,:);
    lpsolver=lptype(P.lpsolver); 
    removetol=1e-3;
    Hii=[P.Hx{i}(:,1:nxr),P.Hu{i}(:,1:nur)];
    Hii=[Hii;eye(nxr+nur);-eye(nxr+nur)];
    try
        xmax=1e4; % To avoid having extreme rays, limit the box to xmax
        %if nn<=1,
            Kii=P.K{i}-[P.Hx{i}(:,nxr+1:nx),P.Hu{i}(:,nur+1:nu)]*P.logic{i}(1:nxb+nub,1);
            Kii=[Kii;xmax*ones(2*(nxr+nur),1)];
            [Hii1,Kii1,isemptypoly]=polyreduce(Hii,Kii,lpsolver,removetol);
            if ~isemptypoly,
                if nxr+nur==2,
                    [aux1,handle]=polyplot(Hii1,Kii1,col,shaded);
                else
                    facethandles=polyplot3d(Hii1,Kii1,col,shaded);
                    handle=facethandles(1);
                end
            end
        % else
%             for j=1:size(P.logic{i},2),
%                 Kii=P.K{i}-[P.Hx{i}(:,nxr+1:nx),P.Hu{i}(:,nur+1:nu)]*P.logic{i}(1:nxb+nub,j);
%                 Kii=[Kii;xmax*ones(2*(nxr+nur),1)];
%                 [Hii1,Kii1,isemptypoly]=polyreduce(Hii,Kii,lpsolver,removetol);
%                 if ~isemptypoly,
%                     z=sum((2.^(0:nxb+nub-1)').*P.logic{i}(1:nxb+nub,j));
%                     [aux1,handle]=polyplot3(Hii1,Kii1,z,col,col);
%                     hold on
%                     drawnow
%                 end
%             end
%         end
    catch
        rethrow(lasterror)
    end
    legLab{i} = sprintf('# %d', i); 
    handles(i)=handle;
end

[LEGH,OBJH,OUTH,OUTM]=legend(handles,legLab);

% Adjust shading of labels to same shading of polygons
flag=1;i=0;FaceAlpha=1; % Look for FaceAlpha
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


xlabel('\theta_1'); 
ylabel('\theta_2');
if nxr+nur==3,
    zlabel('\theta_3');
end
title(sprintf('Number of PWA Regions: %d', P.nr));
grid; 

if nargout==1,
    h=gcf;
end
    