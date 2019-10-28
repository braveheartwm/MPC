function mpqpsol1=pwaplotsection(mpqpsol,index,values,plotflag,colors,fighandle,pauseflag);
% PWAPLOTSECTION: pwaplotsection(sol,index,values,plotflag);
%
% Obtain a section of the partition defined by the explicit MPC controller 
% (or explicit mpqp-solution) 'sol' by fixing theta(index)=values.
%
% sol1=regionsection(sol,index,values,plotflag) stores the new 
% partition in the variable sol1.
%
% plotflag is an optional flag, when plotflag=0 the section is not plotted.
%
%  pwaplotsection(P,fix,values,plotflag,colors) use colors
%  specified in the nr-by-3 array "colors"
%
%  pwaplotsection(P,fix,values,plotflag,colors,fighandle) also specifies the figure handle where the partition is
%  plotted. For subplots, use fighandle='xyz', where (x,y) define the number of subplots 
%  and z the subplot number. See PWAPLOT
%
%  pwaplotsection(P,fix,values,plotflag,colors,fighandle,pauseflag) pause after each plotting 
%  each cell if pauseflag=1  
%
% See also PWAPLOT
%
% (C) 2003-2008 by A. Bemporad

if nargin<4 || isempty(plotflag),
   plotflag=1;
end
if nargin<5,
   colors=[];
end
if nargin<6 || isempty(fighandle),
    fighandle=[];
end
if nargin<7 || isempty(pauseflag),
    pauseflag=0;
end


mpqpsol1=mpqpsol;

values=values(:);

nth=size(mpqpsol.H,2); % Dimension of theta
notindex=setdiff(1:nth,index);

j=0;

mpqpsol1.K=mpqpsol.K-mpqpsol.H(:,index)*values;;
mpqpsol1.H=mpqpsol.H(:,notindex);
mpqpsol1.G=mpqpsol.G+mpqpsol.F(:,index)*values;;
mpqpsol1.F=mpqpsol.F(:,notindex);
mpqpsol1.thmin=mpqpsol.thmin(notindex,:);
mpqpsol1.thmax=mpqpsol.thmax(notindex,:);
mpqpsol1.npar=length(notindex);

if plotflag,
   pwaplot(mpqpsol1,colors,fighandle,pauseflag);
end

aux='Section with ';
for i=1:length(index),
   aux=[aux sprintf('\\theta_{%d}=%5.2f, ',index(i),values(i))];
end   
title(aux)
