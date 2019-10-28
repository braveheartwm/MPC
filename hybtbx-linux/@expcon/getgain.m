function [Fi,Gi,Hi,Ki]=getgain(expcon,reg);
%GETGAIN Get the polyhedron and the gain corresponding to a given region number
%
%   [F,G]=GETGAIN(EXPCON,I) returns the control law u=F*x+G associated
%   with region number I of the PWA map stored in controller EXPCON. 
%
%   [F,G,H,K]=GETGAIN(EXPCON,I) also returns the polyhedral cell H*x<=K
%   corresponding to region number I of the PWA map stored in controller EXPCON. 
%
%   See also EXPCON/GETREGNUM
%
% (C) 2003-2006 by Alberto Bemporad

if nargin<1,
    error('expcon:getgain:none','No EXPCON object supplied.');
end
if ~isa(expcon,'expcon'),
    error('expcon:getgain:obj','Invalid EXPCON object');
end

nr=expcon.nr;
if ~isnumeric(reg) | reg<1 | reg>sum(nr),
    error('expcon:getgain:out',...
        sprintf('Region index out of range (valid range: 1 to %g)',sum(nr)));
end

i1=expcon.i1;
i2=expcon.i2;
nu=expcon.nu;
Hi=expcon.H;
Ki=expcon.K;
Fi=expcon.F;
Gi=expcon.G;

if expcon.info.islin || (expcon.info.ishyb && isinf(expcon.norm)),
    % do nothing
else
    % Hybrid 2-norm, multiple partitions
    cumnr2=cumsum(nr);
    cumnr1=cumnr2-nr+1;
    par=find(and(reg>=cumnr1,reg<=cumnr2));
    reg=reg-cumnr1(par)+1; % region number inside partition #par
    i1=i1{par};
    i2=i2{par};
    Hi=Hi{par};
    Ki=Ki{par};
    Fi=Fi{par};
    Gi=Gi{par};
    
end
Hi=Hi(i1(reg):i2(reg),:);
Ki=Ki(i1(reg):i2(reg),:);
Fi=Fi((reg-1)*nu+1:nu*reg,:);
Gi=Gi((reg-1)*nu+1:nu*reg,:);
