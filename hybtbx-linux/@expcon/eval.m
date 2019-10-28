function [U,region,Useq,cost]=eval(expcon,x);
%EVAL evaluate explicit piecewise affine controller
%   u=EVAL(EXPCON,TH) computes the control action u for the current vector 
%   of parameters TH using the PWA map stored in the controller object EXPCON. 
%
%   The order of states and references in vector TH is the following:
%
%   Linear regulator:   TH=[x(t)],                  the output argument of eval is u(t)
%   Linear tracking:    TH=[x(t);u(t-1);ref.y(t)],  the output argument of eval is u(t)-u(t-1) 
%   Hybrid:             TH=[x(t); ref.xc(t); ref.uc(t); ref.yc(t)], u=u(t)
%                       (x is always [xc;xb]; references on binary vars are always fixed)
%
%   [u,j]=EVAL(EXPCON,TH) also returns the index j of the region of the PWA map
%   corresponding to TH. In case regions overlap, j is the first region where 
%   TH is found to belong to.
%
%   [u,j,Useq]=EVAL(EXPCON,TH) also returns the entire optimal sequence, if this
%   was stored by setting options.sequence=1 when constructing the explicit controller.

% (C) 2003-2004 by Alberto Bemporad

if nargin<1,
    error('expcon:eval:none','No EXPCON object supplied.');
end
if ~isa(expcon,'expcon'),
    error('expcon:eval:obj','Invalid EXPCON object');
end
if nargin<2,
    error('No vector of parameters supplied');
end
if ~isnumeric(x),
    error('Invalid vector of parameters');
end
x=x(:);
if length(x)~=expcon.npar,
    error(sprintf('Expecting %d parameters, %d were supplied',expcon.npar,length(x)));
end
    
if ~expcon.info.isconstr,
   % Linear controller

   U=expcon.F*x;
   region=1;
   return
end

% 2005-10-7: Bound check removed from here to prevent numerical errors
%            generating infeasibility, but done in case infeasibility is detected.
% if any(x>expcon.thmax)|any(x<expcon.thmin),
%    warning('Parameters are outside bounds, control action cannot be determined')
%    U=Inf*ones(expcon.nu,1); %(infeasible)
%    region=-2;
%    return
% end

i1=expcon.i1;
i2=expcon.i2;
H=expcon.H;
K=expcon.K;
F=expcon.F;
G=expcon.G;
nu=expcon.nu;
nr=expcon.nr;
flag=1;

if expcon.info.ishyb,
    sequence=0; % force this to be zero
else
    sequence=expcon.info.sequence;
end

if ~sequence,
    nvar=nu;
else
    nvar=expcon.info.nvar;
end

if expcon.info.islin || (expcon.info.ishyb && isinf(expcon.norm)) || expcon.info.ismpc,
    i=1;
    while i<=nr && flag,
        i1i=i1(i);
        i2i=i2(i);
        Hi=H(i1i:i2i,:);
        if all(Hi*x<=K(i1i:i2i,:)),
            ii=(i-1)*nvar;
            U=F(ii+1:ii+nu,:)*x+G(ii+1:ii+nu,:);
            region=i;
            flag=0;
        end
        i=i+1;
    end
    if nargout>=3,
        if expcon.info.sequence && (expcon.info.islin || expcon.info.ismpc),
            Useq=F(1+(region-1)*nvar:region*nvar,:)*x+G(1+(region-1)*nvar:region*nvar,:);
        else
            % This is just for compatibility
            Useq='not computed';
        end
    end
    if nargout>=4, % This is just for compatibility with the hyb-2-norm case
        cost='not computed';
    end
    
else

    
    
    % Hybrid 2-norm, must compare value functions
    value=Inf;
    for j=1:length(nr), % = number of partitions
        i=1;
        i1j=i1{j};
        i2j=i2{j};
        Hj=H{j};
        Kj=K{j};
        Fj=F{j};
        Gj=G{j};
        nrj=nr(j);
        thisflag=1;
        while i<=nrj && thisflag,
            i1i=i1j(i);
            i2i=i2j(i);
            Hi=Hj(i1i:i2i,:);
            if all(Hi*x<=Kj(i1i:i2i,:)),
                % theta belongs to this region
                H1=expcon.cost{j}.H; % Hessian:       .5*U'HU
                D1=expcon.cost{j}.D; % Linear term:   theta'D'U
                C1=expcon.cost{j}.C; % Affine term:   C'*U
                Y1=expcon.cost{j}.Y; % Constant term: .5*theta'*Y*theta
                V1=expcon.cost{j}.V; % Constant linear term: V'*theta
                d1=expcon.cost{j}.d; % Purely constant term
                
                TT=expcon.cost{j}.TT; % Indices of continuous inputs & slack
                noslack=expcon.cost{j}.noslack; % problem has hard constraints
                nvar=expcon.cost{j}.nvar; % nvar=(nuc+nub)*T+(1-noslack)
                
                thisUseq=Fj(1+(i-1)*nvar:i*nvar,:)*x+Gj(1+(i-1)*nvar:i*nvar,:); % Optimal nvar sequence
                thisU=thisUseq(1:nu); % Optimal u(0)=[uc(0);ub(0)]
                TTthisUseq=thisUseq(TT); % = [uc(0);uc(1);...;uc(T-1)]
                
                % Compute optimal cost V*(x):
                thisvalue=.5*TTthisUseq'*H1*TTthisUseq+x'*D1'*TTthisUseq+.5*x'*Y1*x+C1'*TTthisUseq+V1'*x+d1;
                               
                if thisvalue<value,
                    value=thisvalue;
                    U=thisU;
                    region=sum(nr(1:j-1))+i;
                    if nargout>=3,
                        Useq=thisUseq(1:nvar-(1-noslack)); % [uc(0);ub(0);...;uc(T-1);ub(T-1)]
                    end
                    if nargout>=4,
                        cost=2*thisvalue; % Multiplies by 2, because Hessian was multiplied by .5
                    end
                end
                thisflag=0; % Abandon the current partition
                flag=0; % The solution has been/will be found
            end
            i=i+1;
        end
    end
end

if flag,
    warning('Determining the control action is impossible');
    %regionsection(expcon,3:length(thmin),zeros(length(thmin)-2,1),1);
    
    %flattol=expcon.info.flattol; % To prevent numerical errors
    if any(x>expcon.thmax)|any(x<expcon.thmin),
        warning('Parameters are outside bounds')
        region=-2;
    else
        region=-1;
    end
    U=Inf*ones(expcon.nu,1); %(infeasible)
end

%U=Z-Hinv*F'*x;