function P=fix(P,vartype,varindex,value);
% FIX Fix an input or a state of a PWA system to a given value
%
% P1=FIX(P,vartype,varindex,value) fix variable vartype(varindex) at value 'value'.
%
% 'vartype' is either 'xr', 'xb', 'ur', or 'ub'.
% 'vartype' is either an integer or an array of indices
% 'value' is an array of reals of the same dimension of 'vartype'
%
% See also PWA, PWAPROPS, PLOT.

% (C) 2003 by A. Bemporad

if nargin<1,
    error('pwa:fix:none','No PWA object supplied.');
end
if ~isa(P,'pwa'),
    error('pwa:fix:obj','Invalid PWA object');
end

if nargin<4,
    error('pwa:fix:nargin','Incorrect number of inputs');
end
if ~ischar(vartype) | (...
        ~strcmp(lower(vartype),'xr') & ...
        ~strcmp(lower(vartype),'xb') & ...
        ~strcmp(lower(vartype),'ur') & ...
        ~strcmp(lower(vartype),'ub')),
    error('pwa:fix:type','Vartype must be either ''xr'', ''xb'', ''ur'', or ''ub''.');
end

nur=P.nur;
nub=P.nub;
nxr=P.nxr;
nxb=P.nxb;

vartype=lower(vartype);

switch vartype
    case 'xr'
        nmax=nxr;
    case 'xb'
        nmax=nxb;
    case 'ur'
        nmax=nur;
    case 'ub'
        nmax=nub;
end

if ~isreal(varindex) | min(varindex)<0 | max(varindex>nmax),
    error('pwa:fix:bounds',sprintf('Varindex must have at most %d components',nmax));
end
len=length(varindex);
if ~isreal(value) | length(value)~=len,
    error('pwa:fix:value',sprintf('Value must be an %d-dimensional array of reals',len));
end

value=value(:);
varindex=varindex(:)';

for i=1:P.nr,
    switch vartype
        case 'xr'
            P.f{i}=P.f{i}+P.A{i}(:,varindex)*value;
            P.A{i}(:,varindex)=[];
            P.A{i}(varindex,:)=[];
            P.B{i}(varindex,:)=[];
            P.f{i}(varindex,:)=[];
            P.K{i}=P.K{i}-P.Hx{i}(:,varindex)*value;
            P.Hx{i}(:,varindex)=[];
            if i==1,
                P.nx=P.nx-len;
                P.nxr=P.nxr-len;
            end
        case 'ur'
            P.f{i}=P.f{i}+P.B{i}(:,varindex)*value;
            P.B{i}(:,varindex)=[];
            P.K{i}=P.K{i}-P.Hu{i}(:,varindex)*value;
            P.Hu{i}(:,varindex)=[];
            if i==1,
                P.nu=P.nu-len;
                P.nur=P.nur-len;
            end
        case 'xb'
            P.Lf{i}=P.Lf{i}+P.LA{i}(:,varindex)*value;
            P.LA{i}(:,varindex)=[];
            P.LA{i}(varindex,:)=[];
            P.LB{i}(varindex,:)=[];
            P.Lf{i}(varindex,:)=[];
            % Binary inputs come after continuous inputs
            P.K{i}=P.K{i}-P.Hx{i}(:,nxr+varindex)*value;
            P.Hx{i}(:,nxr+varindex)=[];
            if i==1,
                P.nx=P.nx-len;
                P.nxb=P.nxb-len;
            end
        case 'ub'
            P.Lf{i}=P.Lf{i}+P.LB{i}(:,varindex)*value;
            P.LB{i}(:,varindex)=[];
            % Binary inputs come after continuous inputs
            P.K{i}=P.K{i}-P.Hu{i}(:,nur+varindex)*value;
            P.Hu{i}(:,nur+varindex)=[];
            if i==1,
                P.nu=P.nu-len;
                P.nub=P.nub-len;
            end
    end
end