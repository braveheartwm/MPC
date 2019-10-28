function [h,P1]=plotsection(P,fix,values,plotflag,colors);
%PLOTSECTION Plot sections of polyhedral partitions 
%  associated with PWA systems (only 2D and 3D) 
% 
%  PLOTSECTION(P,fix,values) plots a section of the 
%  partition defined by the pwa system P by fixing certain continuous
%  inputs/states to certain values.
%
%    fix.x  = continuous states that are fixed at given values
%    fix.u  = continuous inputs that are fixed at given values
%    values.x  = values of continuous states that have been fixed
%    values.u  = values of continuous inputs that have been fixed
%
%  h=PLOTSECTION(P,...) returns the figure handle used for plotting
%
%  [h,P1]=PLOTSECTION(P,...) returns the reduced partition.
%
%  [h,P1]=PLOTSECTION(P,fix,values,plotflag) does not 
%  produce any plot if plotflag=0.
%
%  [h,P1]=PLOTSECTION(P,fix,values,plotflag,colors) use colors
%  specified in the P.nr-by-3 array "colors"

% (C) 2003 by A. Bemporad

if nargin<1,
    error('pwa:plotsection:none','No PWA object supplied.');
end
if ~isa(P,'pwa'),
    error('pwa:plotsection:obj','Invalid PWA object');
end
if nargin<4 | isempty(plotflag),
   plotflag=1;
end
if nargin<5,
   colors=[];
end

P1=P;
if nargin==1,
    plot(P1);
    return
end

P1=P;

if nargin<2 | isempty(fix),
    fix=struct('x',[],'u',[]);
else
    if ~isstruct(fix),
        error('''fix'' must be a structure with fields ''x'' and ''u''');
    end
end
if isfield(fix,'x'),
    xfix=fix.x(:);
else
    xfix=[];
end
if isfield(fix,'u'),
    ufix=fix.u(:);
else
    ufix=[];
end

if any(xfix>P.nxr),
    error(sprintf('''fix.x'' must contain indices between 1 and %d',P.nxr));
end
if any(ufix>P.nur),
    error(sprintf('''fix.u'' must contain indices between 1 and %d',P.nur));
end

if nargin<3 | isempty(values),
    value=struct('x',[],'u',[]);
else
    if ~isstruct(values),
        error('''values'' must be a structure with fields ''x'' and ''u''');
    end
end

if isfield(values,'x'),
    xvals=values.x(:);
else
    xvals=[];
end
if isfield(values,'u'),
    uvals=values.u(:);
else
    uvals=[];
end
fx=length(xfix);
fu=length(ufix);

if length(xvals)~=fx,
    error('Fixed state indices and values do not match');
end
if length(uvals)~=fu,
    error('Fixed input indices and values do not match');
end


getrid=[];
for i=1:P.nr,
    if fx>0, 
        P1.f{i}=P.f{i}+P.A{i}(:,xfix)*xvals;
        P1.A{i}(:,xfix)=[];
        P1.Lf{i}=P.Lf{i}+P.LA{i}(:,xfix)*xvals;
        P1.LA{i}(:,xfix)=[];
        P1.K{i}=P.K{i}-P.Hx{i}(:,xfix)*xvals;
        P1.Hx{i}(:,xfix)=[];
    end
    if fu>0, 
        P1.f{i}=P1.f{i}+P.B{i}(:,ufix)*uvals;
        P1.B{i}(:,ufix)=[];
        P1.Lf{i}=P1.Lf{i}+P.LB{i}(:,ufix)*uvals;
        P1.LB{i}(:,ufix)=[];
        P1.K{i}=P1.K{i}-P.Hu{i}(:,ufix)*uvals;
        P1.Hu{i}(:,ufix)=[];
    end
    
    [A1,B1,isemptypoly,keptrows]=polyreduce([P1.Hx{i} P1.Hu{i}],P1.K{i},lptype(P.lpsolver));
    if ~isemptypoly,
        P1.Hx{i}=P1.Hx{i}(keptrows,:);
        P1.Hu{i}=P1.Hu{i}(keptrows,:);
        P1.K{i}=P1.K{i}(keptrows,:);
    else
        getrid=[getrid,i];
    end
end
P1.A(getrid)=[];
P1.B(getrid)=[];
P1.f(getrid)=[];
P1.LA(getrid)=[];
P1.LB(getrid)=[];
P1.Lf(getrid)=[];
P1.logic(getrid)=[];
P1.Hx(getrid)=[];
P1.Hu(getrid)=[];
P1.K(getrid)=[];

P1.nr=P1.nr-length(getrid);
P1.nx=P.nx-fx;
P1.nu=P.nu-fu;
P1.nxr=P.nxr-fx;
P1.nur=P.nur-fu;

if plotflag,
   h=plot(P1,colors);
end

aux='Section with ';
for i=1:length(xfix),
   aux=[aux sprintf('x_{%d}=%5.2f, ',xfix(i),xvals(i))];
end   
for i=1:length(ufix),
   aux=[aux sprintf('u_{%d}=%5.2f, ',ufix(i),uvals(i))];
end   
title(aux);

if nargout==0,
    clear h
end
if nargout==0,
    clear h expcon1
end