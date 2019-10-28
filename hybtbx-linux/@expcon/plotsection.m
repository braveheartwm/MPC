function [h,expcon1]=plotsection(expcon,index,values,fighandle,plotflag,pauseflag,overlap);
%PLOTSECTION Plot sections of polyhedral partitions 
%  associated with explicit controllers (only 2D and 3D) 
% 
%  PLOTSECTION(expcon,indices,values) plots a section of the 
%  partition defined by controller expcon by fixing theta(indices)=values.
%
%  PLOTSECTION(expcon,indices,values,fighandle) also specifies the handle 
%  of the figure where the partition should be plotted.
%
%  h=PLOTSECTION(expcon,...) returns the figure handle used for plotting
%
%  [h,expcon1]=PLOTSECTION(expcon,...) returns the reduced partition.
%
%  [h,expcon1]=PLOTSECTION(expcon,indices,values,fighandle,0) does not 
%  produce any plot;
%
% (C) 2003 by A. Bemporad


if nargin<1,
    error('expcon:move:none','No EXPCON object supplied.');
end
if ~isa(expcon,'expcon'),
    error('expcon:move:obj','Invalid EXPCON object');
end
if nargin<7 | isempty(overlap),
   overlap=0;
end
if nargin<6 | isempty(pauseflag),
   pauseflag=0;
end
if nargin<5 | isempty(plotflag),
   plotflag=1;
end
if nargin<4,
    fighandle=[];
end
if nargin==1,
    expcon1=expcon;
    if size(expcon.H,2)>3,
        error('Sorry, only 2D and 3D plots supported. Try fixing some of the parameters')
    end
    plot(expcon);
    return
end

sol=struct(expcon);
sol1=sol;

values=values(:);

nth=sol.npar; % Dimension of theta
if any(index>nth),
    error(sprintf('Indices are too large, parameter vector has dimension %d',nth));
end
notindex=setdiff(1:nth,index);

if length(notindex)>3 | length(notindex)<2,
    error('Sorry, only 2D and 3D plots supported. Try changing the number of fixed parameters')
end
j=0;

NR=sol.nr; %=length(i1);
NP=length(NR);

if ~iscell(sol1.H), % Single solution
    sol1.K=sol.K-sol.H(:,index)*values;
    sol1.H=sol.H(:,notindex);
    sol1.G=sol.G+sol.F(:,index)*values;
    sol1.F=sol.F(:,notindex);
    sol1.thmin=sol.thmin(notindex,:);
    sol1.thmax=sol.thmax(notindex,:);
    sol1.npar=length(notindex);
else
    for i=1:NP % for all partitions
        sol1.K{i}=sol.K{i}-sol.H{i}(:,index)*values;
        sol1.H{i}=sol.H{i}(:,notindex);
        sol1.G{i}=sol.G{i}+sol.F{i}(:,index)*values;
        sol1.F{i}=sol.F{i}(:,notindex);
        sol1.thmin=sol.thmin(notindex,:);
        sol1.thmax=sol.thmax(notindex,:);
        sol1.npar=length(notindex);
    end
end

xlab=sprintf('\\theta_{%d}',notindex(1));
ylab=sprintf('\\theta_{%d}',notindex(2));

if plotflag,
   h=pwaplot(sol1,[],fighandle,pauseflag,overlap,xlab,ylab);
else
    h=0;
end

%aux='Section with ';
%for i=1:length(index),
%   aux=[aux sprintf('\\theta_{%d}=%5.2f, ',index(i),values(i))];
%end
%if plotflag,
    %title(aux);
%    xlabel(sprintf('\\theta_{%d}',notindex(1)));
%    ylabel(sprintf('\\theta_{%d}',notindex(2)));
%end

sol1.npar=size(sol1.H,2);
expcon1=class(sol1,'expcon');

if nargout==0,
    clear h expcon1
end