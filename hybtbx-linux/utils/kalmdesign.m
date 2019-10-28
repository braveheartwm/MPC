function [lincon,Kest,M]=kalmdesign(lincon,Q,R,ymeasured)
% KALMDESIGN Design Kalman filter for constrained optimal controllers
%
% Type "help kalmanhelp" for help.

% (C) 2003-2009 by Alberto Bemporad

Qdef=0.1;  % Default variance of state noise
Rdef=1;    % Default variance of output noise

if nargin<1,
    error('lincon:kalman:none','No controller supplied.');
end

nx=lincon.nx;
if nargin<2 | isempty(Q),
    Q=Qdef*eye(nx);
else
    errmsg=sprintf('Q must be a %d-by-%d positive semidefinite matrix',nx,nx);
    errflag=0;
    if prod(size(Q))==1,
        Q=Q*eye(nx);
    else
        if ~all(size(Q)==[nx nx]),
            errflag=1;
        end
    end
    [Rchol,p]=chol(Q+sqrt(eps)*eye(size(Q))); % Positive semidefinite is ok.
    if p>0 | errflag,
        error(errmsg); 
    end 
end

ny=lincon.ny;
if nargin<4 | isempty(ymeasured),
    ymeasured=(1:ny)';
else
    ymeasured=round(ymeasured(:));
    if any(ymeasured>ny) | any(ymeasured<1),
        error(sprintf('Invalid output index, must be between 1 and %d',ny));
    end
end
nym=length(ymeasured);

% For backwards compatibility:
if iscell(lincon.Observer),
    lincon.Observer=lincon.Observer{1};
end

model=lincon.model;
if isa(model,'cell'); % Time-varying model, get the first model for current time t for estimation
    model=lincon.model{1};
end

yzerocon=model.Userdata.yzerocon;

if nargin<3 || isempty(R),
    R=Rdef*eye(nym);
else
    errmsg=sprintf('R must be a %d-by-%d positive semidefinite matrix',nym,nym);
    errflag=0;
    if numel(R)==1,
        R=R*eye(nym);
    else
        if ~all(size(R)==[nym nym]),
            errflag=1;
        end
    end
    [Rchol,p]=chol(R+sqrt(eps)*eye(size(R))); % Positive semidefinite is ok.
    if p>0 || errflag,
        error(errmsg); 
    end 
end

nu=lincon.nu;

%      x[n+1|n] = Ax[n|n-1] + Bu[n] + L(y[n] - Cx[n|n-1] - Du[n])
%
%       y[n|n]  = Cx[n|n] + Du[n]
%       x[n|n]  = x[n|n-1] + M(y[n] - Cx[n|n-1] - Du[n])

[A,B,C,D]=ssdata(model);
Cm=C(ymeasured,:);
Dm=D(ymeasured,:);
ts=lincon.ts;
extmodel=ss(A,[B eye(nx)],Cm,[Dm zeros(nym,nx)],ts);
[K,L,P,M]=kalman(extmodel,Q,R);
if ~norm(Dm)<1e-8 && all(yzerocon==0),
    % If yzerocon=0, no constraints on outputs for k=0 ==> check feedthrough
    error('Direct feedthrough from inputs to measured outputs is not possible');
end

Ae=(A-L*Cm);
Be=[B L]; % More generally: [B-L*Dm L];
Ce=eye(nx);
De=zeros(nx,nym+nu);
Kest=ss(Ae,Be,Ce,De,ts);
lincon.Observer=struct('M',M,'Cm',Cm,'nym',size(Cm,1));
%lincon.model.Userdata.yzerocon=yzerocon;
