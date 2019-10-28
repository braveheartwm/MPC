function [cost,soft]=chkcost(cost,type,nx,nu,ny,costdef,A,B);

%CHKCOST Check cost structure
%
%(C) 2003 by A. Bemporad

if ~isa(cost,'struct'),
    error('COST must be a structure of weights on system variables');
end
tracking=strcmp(type,'track');

fields={'Q','R','P','K','S','T','rho'};

islqr=0;
islyap=0;
s=fieldnames(cost); % get field names
for i=1:length(s),
    Name=s{i};
    name=lower(Name);
    
    j=find(ismember(lower(fields),name)); % locate name within 'fields'
    if isempty(j), % field inexistent
        error(sprintf('The field ''%s'' in COST is invalid',Name));
    else
        aux=fields{j};
        eval(['w=cost.' Name ';']);
        eval(['wdef=costdef.' Name ';']);
        if ~isa(w,'double') & ~strcmp(name,'p'),
            error(['COST.' Name ' must be real valued.']);
        else
            % Check correctness of weight
            switch name
                case {'q','p'}
                    n=nx;
                    if tracking,
                        warning(sprintf('Weights on states will be ignored, controller type is ''%s''',type));
                    end
                case 'r'
                    n=nu;
                    if tracking,
                        warning(sprintf('Weights on inputs will be ignored, controller type is ''%s''',type));
                    end
                case 't'
                    n=nu;
                    if ~tracking,
                        warning(sprintf('Weights on input increments will be ignored, controller type is ''%s''',type));
                    end
                case 's'
                    n=ny;
                    if ~tracking,
                        warning(sprintf('Weights on outputs will be ignored, controller type is ''%s''',type));
                    end
                case 'rho'
                    n=1;
            end
            if ~strcmp(name,'k'),
                if ~(strcmp(name,'p') & ischar(w)),
                    w=chkwght(w,n,Name,wdef);
                end
            else
                w=chkgain(w,nu,nx,wdef);
            end
            eval(['cost.' aux '=w;']);
        end
    end
end   

% Define missing fields
for i=1:length(fields),
    aux=fields{i};
    if ~isfield(cost,aux),
        if (~tracking & ~isempty(findstr('QRPKrho',aux))) | ...
                (tracking & ~isempty(findstr('STrho',aux))), 
            eval(['wdef=costdef.' aux ';']);
            eval(['cost.' aux '=wdef;']);
        end
    end
end

if ~tracking,
    if ischar(cost.P),
        switch lower(cost.P)
            case 'lqr'
                islqr=1;
            case 'lyap'
                islyap=1;
            otherwise
                error('Unknown option for terminal weight COST.P');
        end
        if islqr,
            [KLQ,cost.P]=dlqr(A,B,cost.Q,cost.R); % Solution of Riccati equation
            cost.K=-KLQ;
            % u=-KLQ x can be compared with mp-QP solution in the unconstrained region 
        elseif islyap,
            cost.P=dlyap(A',cost.Q);         % Solution of Lyapunov equation
            cost.K=zeros(1,nx);
        end
    else
        if isempty(cost.K),
            warning('No gain K specified, assuming K=0');
            cost.K=zeros(nu,nx);
        end
    end
end

soft=isfinite(cost.rho);

%-----------------
function w=chkwght(w,n,name,wdef);

if isempty(w),
    w=wdef;
    return
end
[nrow,ncol]=size(w);
if nrow~=n | ncol~=n,
    error(sprintf('Invalid dimensions of weight COST.%s (required dimension: %d-by-%d)',name,n,n));
end
if ~strcmp(lower(name),'rho'),
    if any(isinf(w(:))),
        error(sprintf('Infinite values in weight COST.%s are not allowed.',name)); 
    end 
    if ~(max(max(abs(w-w'))) <= eps^(2/3)*max(max(abs(w)))),
        warning(sprintf('Weight H=COST.%s is not symmetric. Setting H=(H+H'')/2',name));
        w=(w+w')/2;
    end
    [R,p]=chol(w+sqrt(eps)*eye(size(w))); % Positive semidefinite is ok.
    if p>0,
        error(sprintf('Weight COST.%s is not positive definite.',name)); 
    end 
end
%end chkwght

%-----------------
function w=chkgain(w,nu,nx,wdef);

if isempty(w),
    w=wdef;
    return
end
[nrow,ncol]=size(w);
if nrow~=nu | ncol~=nx,
    error(sprintf('Invalid dimensions of feedback gain COST.K (required dimension: %d-by-%d)',name,nu,nx));
end
if any(isinf(w(:))),
    error(sprintf('Infinite values in feedback gain COST.K are not allowed.',name)); 
end 
%end chkgain

