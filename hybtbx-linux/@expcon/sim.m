function [XX,UU,TT,YY,II]=sim(expcon,model,refs,x0,Tstop,u0,verbose)
% SIM Closed-loop simulation of explicit constrained controllers (linear/hybrid)
%
% [X,U,T,Y,I]=SIM(EXPCON,MODEL,refs,x0,Tstop,u0,verbose) simulates the closed-loop
% of the linear or hybrid system MODEL with the controller EXPCON.
% Usually, EXPCON is based on model MODEL (nominal closed-loop).
%
% Input: EXPCON      = explicit controller (linear or hybrid)
%        refs        = structure or references with fields:
%                      .y  output references    (linear systems w/tracking and hybrid systems)
%                      .x  state references     (hybrid systems)
%                      .u  input references     (hybrid systems)
%        x0          = initial state
%	     Tstop       = total simulation time (e.g., in seconds)
%        u0          = input at time t=-1 (only for linear systems w/tracking)
%        verbose     = verbosity level (0,1)
%
% For linear models:
% refs.y has as many columns as the number of outputs
%
% For hybrid models:
% refs.y has as many columns as the number of weighted outputs
% refs.x has as many columns as the number of weighted states
% refs.u has as many columns as the number of weighted inputs
%
% Output arguments:
% X is the sequence of states, with as many columns as the number of states.
% U is the sequence of inputs, with as many columns as the number of inputs.
% T is the vector of time steps (equally spaced by EXPCON.Ts).
% Y is the sequence of outputs, with as many columns as the number of
% outputs (only meaningful for linear models)
% I is the sequence of region numbers
%
% Without output arguments, SIM produces a plot of the trajectories
%
% EXPCON objects based on time-varying prediction models/weights/limits can be
% simulated in closed-loop with LTI models. Time-varying simulation models are 
% not supported, use custom for-loops instead.

% (C) 2003-2009 by Alberto Bemporad

if nargin<1,
    error('expcon:sim:none','No EXPCON object supplied.');
end
if ~isa(expcon,'expcon'),
    error('expcon:sim:obj','Invalid EXPCON object');
end

if nargin<2 || isempty(model),
    model=expcon.model;
    warning('expcon:sim:defaultmodel','Using prediction model as the simulation model');
end

islin=expcon.info.islin;
ishyb=expcon.info.ishyb;
lintracking=expcon.info.lintracking';

if islin,
    nx=expcon.nx;
    nu=expcon.nu;
    ny=expcon.ny;
end
if ishyb,
    nx=model.nx;
    nu=model.nu;
    ny=model.ny;
end

if nargin<4|isempty(x0),
    x0=zeros(nx,1);
else
    if ~isnumeric(x0) | length(x0)~=nx,
        error(sprintf('The initial state should be a vector of dimension %d',nx));
    end
    x0=x0(:);
end
if nargin<6|isempty(u0),
    u0=zeros(nu,1);
else
    if ~isnumeric(u0) | length(u0)~=nu,
        error(sprintf('The previous input vector should be a vector of dimension %d',nu));
    end
    u0=u0(:);
end
if nargin<5|isempty(Tstop),
    Tstop=1;
else
    if ~isnumeric(Tstop) | Tstop<0,
        error('Simulation time must be a nonnegative scalar');
    end
    Tstop=max(Tstop);
end
Ts=expcon.ts;

%-----------------
% Check refs
%-----------------
refsdef=[];
if islin,
    if lintracking,
        refsdef.y=zeros(1,ny);
        nry=ny;
    else
        nry=[];
    end
    nrx=[];
    nru=[];
    nrz=[];
elseif ishyb,
    nry=length(expcon.info.refsignals.y);
    nru=length(expcon.info.refsignals.u);
    nrx=length(expcon.info.refsignals.x);
    nrz=[];
    refsdef.y=zeros(1,nry);
    refsdef.x=zeros(1,nrx);
    refsdef.u=zeros(1,nru);
end        
if nargin<4 | isempty(refs),
    refs=refsdef;
end

Ttot=ceil(Tstop/Ts);
isexp=1;
[refs,Tdef]=chkrefs(refs,islin,ishyb,nrx,nru,nry,nrz,refsdef,lintracking,Ttot,isexp);

if ishyb,
    % Eliminate refs that were fixed
    refs.x(:,expcon.info.fixref.x)=[];
    refs.y(:,expcon.info.fixref.y)=[];
    refs.u(:,expcon.info.fixref.u)=[];
end

if nargin<5|isempty(Tstop),
    Tstop=Tdef*Ts;
end

if nargin<7|isempty(verbose),
    verbose=1;
end

% Initialize 
XX=[];
UU=[];
II=[];

TT=(0:Ttot-1);

x=x0; % Initial state (not including initial input u(-1) in case of lintracking)
u=u0;

if expcon.info.islin,
    if isa(model,'cell'),
        error('expcon:sim:timevarying','Time-varying simulation models are not supported');
    end
    if ~isa(model,'lti'),
        error('expcon:sim:obj','Invalid MODEL, it should be an LTI object');
    end
    if ~isa(model,'ss'),
        model=ss(model);
    end
    if hasdelay(model),
        % Convert delays to states
        model=delay2z(model);
    end
    if abs(Ts-model.ts)>1e-10,
        model=d2d(model,Ts);
    end
    [nxm,num]=size(model.b);
    nym=size(model.c,1);
    if nxm~=nx,
        error(sprintf('MODEL has %g states, while EXPCON is based on a model with %g states',nxm,nx));
    end
    if nym~=ny,
        error(sprintf('MODEL has %g outputs, while EXPCON is based on a model with %g outputs',nym,ny));
    end
    if num~=nu,
        error(sprintf('MODEL has %g inputs, while EXPCON is based on a model with %g inputs',num,nu));
    end
    A=model.A;
    B=model.B;
    
    if lintracking,
        sp=refs.y;
    else
        sp=[];
    end
    
    RR=sp;
    
    for t=TT,
        XX=[XX;x'];
        if lintracking,
            r=RR(t+1,:)';
            theta=[x;u;r];
        else
            theta=x;
        end
        
        [vec,i]=eval(expcon,theta);
        if lintracking,
            u=u+vec;
        else
            u=vec;
        end
        
        %disp(sprintf('t=%d, Region #%d',t,i));
        %if t/10==round(t/10),
        %   disp(sprintf('t=%d',t));
        %end
        
        if verbose,
            fprintf('t=%3d, reg=%3d | ',t,i);
            if ((t+1)/4)==round((t+1)/4),
                fprintf('\n');
            end
        end   
        x=A*x+B*u; %+3*(rand(size(x0))-.5);
        
        %         if compareQP %1=compare with QP,
        %             [u,i]=exp_mpc_m(expmpc,theta);
        %             swarn=warning;
        %             warning off
        %             u1=qp(Q,C*theta,G,W+S*theta);
        %             warning(swarn);
        %             u1=I1*u1;
        %             nU=norm(u1-u);
        %             if (nU>1e-4),
        %                 warning([sprintf('t=%d, norm(Uqp(1)-UmpQP(1))=',t) num2str(nU)])
        %             end
        %         end
        %fprintf('.');
        UU=[UU;u'];
        II=[II;i];
    end
    YY=XX*model.C'+UU*model.D';
else % ishyb
    if ~isa(model,'pwa') & ~isa(model,'mld'),
        error('expcon:sim:obj','Invalid MODEL');
    end
    RR=[refs.x,refs.u,refs.y];
    YY=[];
    
    for t=TT,
        XX=[XX;x'];
        r=RR(t+1,:)';
        theta=[x;r];
        
        [u,i]=eval(expcon,theta);
        
        if verbose,
            fprintf('t=%3d, reg=%3d | ',t,i);
            if ((t+1)/4)==round((t+1)/4),
                fprintf('\n');
            end
        end   
        [x,y]=update(model,x,u);
        UU=[UU;u'];
        YY=[YY;y'];
        II=[II;i];
    end
end    
if verbose,
    fprintf('\n\n');
end
%XX1=XX;
%UU1=UU;

TT=TT(:)*Ts; % time vector in actual time units

if nargout==0,
    h=gcf;
    clf;
    set(h,'position',[ 86   171   794   494],'userdata','SIM');
    
    if isnan(lintracking),
        lintracking=0;
    end
    subplot(221)
    for i=1:ny,
        plot(TT,YY(:,i));
        %stairs(TT,YY);
        hold on
        if lintracking,
            plot(TT,RR(:,i),'r');
            %stairs(TT,RR);
        end
        if ishyb & any(ismember(expcon.info.refsignals.y,i)),
            iy=find(expcon.info.fixref.y==i);
            if ~isempty(iy),
                plot(TT,ones(size(TT))*expcon.info.valueref.y(iy),'r');
            else 
                plot(TT,refs.y(:,i),'r');
            end
        end
    end
    hold off
    grid
    title('output y(t)')
    
    
    subplot(222)
    for i=1:nx,
        plot(TT,XX(:,i));
        %stairs(TT,XX(:,i));
        hold on
        if ishyb & any(ismember(expcon.info.refsignals.x,i)),
            ix=find(expcon.info.fixref.x==i);
            if ~isempty(ix),
                plot(TT,ones(size(TT))*expcon.info.valueref.x(ix),'r');
            else 
                plot(TT,refs.x(:,i),'r');
            end
        end
    end
    hold off
    grid
    title('state x(t)')
    
    subplot(223)
    for i=1:nu,
        stairs(TT,UU(:,i));
        hold on
        if ishyb & any(ismember(expcon.info.refsignals.u,i)),
            iu=find(expcon.info.fixref.u==i);
            if ~isempty(iu),
                plot(TT,ones(size(TT))*expcon.info.valueref.u(iu),'r');
            else 
                plot(TT,refs.u(:,i),'r');
            end
        end
    end
    grid
    hold off
    title('input u(t)')
    
    subplot(224)
    stairs(TT,II);
    grid
    title('region i(t)')   
end