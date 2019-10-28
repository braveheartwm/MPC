function [uout,Opt,Activeset]=eval(lincon,x,r,u,qpsolver,verbose)

% EVAL Control move based on QP optimization and linear model 
%
% u=EVAL(lincon,x) returns the control move u(t)=f(x(t)) where x(t)=x 
% is the current state (only regulation to the origin).
%
% u=EVAL(lincon,x,r,uold) returns the control move u(t)=f(x(t),u(t-1),r(t)) 
% where r(t)=r is the current ouput reference, u(t-1)=uold is the previous input.
%
% u=EVAL(lincon,x,r,uold,qpsolver) use a specific QP solver (type HELP QPTYPE for details)
%
% NOTE: the output argument u is the input increment u(t)-u(t-1) if lincon 
% is of type 'track', or u(t) if of type 'reg'. Similarly, the output
% sequence Uopt is either a sequence of input increments or of inputs.
%
% [u,Opt]=EVAL(lincon,x,r,uold,qpsolver) also returns the optimal
% solution of the finite-horizon optimal control problem:
% 
% Opt.u = optimal input sequence
% Opt.x = optimal state sequence
% Opt.y = optimal output sequence
% Opt.t = sequence of prediction times
% Opt.slack = optimal value of slack variable
%
% Opt.u (.x, .y) has as many columns as the number of inputs (states, outputs)
% as many rows as the prediction horizon.
%
% [u,Opt,Activeset]=EVAL(lincon,x,r,uold,qpsolver) also returns the active set
% and the corresponding critical region in structure Activeset:
%
% Activeset.i = indices of active constraints. The combination of active constraints
%               is reduced to get a matrix of active constraints with linearly independent rows
%
% Activeset.H and .K  = polyhedral representation of critical region
%               {H*th<=K}, where th is either x (regulation) or [x;u;r]
%               (tracking)
%
% Activeset.Rcheb = Chebychev radius of the critical region {H*th<=K}
%
% Activeset.F and .G  = optimal feedback gain u=F*th+G
%
% See also LINCON.

% (C) 2003-2009 by Alberto Bemporad

if ~exist('U'), % Previous optimal sequence
    persistent U 
    U=[];
elseif length(U)~=(lincon.nvar+lincon.soft),
    U=[]; % U may exists from a previous run, reset it
end

if nargin<1,
    error('lincon:eval:none','No LINCON object supplied.');
end
if ~isa(lincon,'lincon'),
    error('lincon:eval:obj','Invalid LINCON object');
end

if nargin<5 || isempty(qpsolver),
    qpsolver=[];
end

nx=lincon.nx;
nu=lincon.nu;
tracking=strcmp(lincon.type,'track');

if tracking,
    theta=[x(:);u(:);r(:)];
else
    theta=x(:);
end

[U,la,how]=qpsol(lincon.Q,lincon.C*theta,lincon.G,lincon.W+lincon.S*theta,[],[],U,qptype(qpsolver),lincon.Qinv);
if ~strcmp(how,'ok'),
    error(sprintf('QP problem is %s',how));
end
uout=lincon.I1*U;

if nargout>1,
    istimevarying=isa(lincon.model,'cell');
    if ~istimevarying,
        interval=lincon.model.Userdata.interval;
    else
        interval=lincon.model{1}.Userdata.interval;
    end
    N=interval.N;
    Nu=interval.Nu;
    Ustar=U;
    if lincon.soft,
        slack=Ustar(end);
        Ustar=Ustar(1:end-1);
    else
        slack=0;
    end
    
    if tracking,
        DUopt=reshape(Ustar,nu,Nu)';
        Uopt=cumsum(DUopt)+ones(Nu,1)*u(:)';
    else
        Uopt=reshape(Ustar,nu,Nu)';
    end
    Uopt=[Uopt;ones(N-Nu,1)*Uopt(end,:)];
    
    ny=lincon.ny;
    Yopt=zeros(N,ny);
    Xopt=zeros(N,nx);
    Topt=zeros(N,1);
    xopt=x(:);
    model=lincon.model;
    for k=0:N-1,
        uopt=Uopt(k+1,:)';
        if istimevarying,
            model=lincon.model{k+1};
        end
        Yopt(k+1,:)=(model.C*xopt+model.D*uopt)';
        Xopt(k+1,:)=xopt';
        xopt=model.A*xopt+model.B*uopt;
        Topt(k+1)=k;
    end
    Opt=struct('u',Uopt,'x',Xopt,'y',Yopt,'t',Topt);
end

if nargout>=3,
    Activeset=one_explicit(lincon,theta,U,la);
end


