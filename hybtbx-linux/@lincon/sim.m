function [XX,UU,TT,YY]=sim(lincon,model,refs,x0,Tstop,u0,qpsolver,verbose)
% SIM Closed-loop simulation of constrained optimal controllers for linear systems
%
% [X,U,T,Y]=SIM(LINCON,MODEL,refs,x0,Tstop,u0,qpsolver,verbose) simulates 
% the closed-loop of the linear system MODEL with the controller LINCON based 
% on quadratic programming.
% Usually, LINCON is based on model MODEL (nominal closed-loop).
%
% Input: LINCON      = optimal controller
%        refs        = structure or references with fields:
%                      .y  output references  (only for tracking)
%        x0          = initial state
%	     Tstop       = total simulation time  (total number of steps = Tstop/LINCON.Ts)
%        u0          = input at time t=-1     (only for tracking)
%        qpsolver    = QP solver (type HELP QPSOL for details)
%        verbose     = verbosity level (0,1)
%
% refs.y has as many columns as the number of outputs
%
% Output arguments:
% X is the sequence of states, with as many columns as the number of states.
% U is the sequence of inputs, with as many columns as the number of inputs.
% T is the vector of time steps.
% I is the sequence of region numbers
% Y is the sequence of outputs, with as many columns as the number of outputs.
%
% Without output arguments, SIM produces a plot of the trajectories
%
% LINCON objects based on time-varying prediction models/weights/limits can be
% simulated in closed-loop with LTI models. Time-varying simulation models are 
% not supported, use custom for-loops instead.

% (C) 2003-2012 by Alberto Bemporad

if nargin<1,
    error('lincon:sim:none','No LINCON object supplied.');
end
if ~isa(lincon,'lincon'),
    error('lincon:sim:obj','Invalid LINCON object');
end

if nargin<2 || isempty(model),
    model=lincon.model;
    warning('lincon:sim:defaultmodel','Using prediction model as the simulation model');
end

tracking=strcmp(lincon.type,'track');

nx=lincon.nx;
nu=lincon.nu;
ny=lincon.ny;

if nargin<4 || isempty(x0),
    x0=zeros(nx,1);
end
if nargin<6 || isempty(u0),
    u0=zeros(nu,1);
end
if nargin<5,
    Tstop=[];
else
    if ~isnumeric(Tstop) || Tstop<0,
        error('Simulation time must be a nonnegative scalar');
    end
    Tstop=max(Tstop);
end
Ts=lincon.ts;

%-----------------
% Check refs
%-----------------
refsdef=[];
if tracking,
    refsdef.y=zeros(1,ny);
end
if nargin<4 || isempty(refs),
    refs=refsdef;
end

[refs,Tdef]=chkrefs(refs,1,0,nx,nu,ny,0,refsdef,tracking,round(Tstop/Ts));

if nargin<5 || isempty(Tstop),
    Tstop=Tdef*Ts;
end

if nargin<7,
    qpsolver=lincon.QPsolver; % default qp solver
end
if nargin<8 || isempty(verbose),
    verbose=1;
end

if isa(model,'cell'),
    error('lincon:sim:timevarying','Time-varying simulation models are not supported');
end
if ~isa(model,'lti'),
    error('lincon:sim:obj','Invalid MODEL, it should be an LTI object');
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
    error(sprintf('MODEL has %g states, while LINCON is based on a model with %g states',nxm,nx));
end
if nym~=ny,
    error(sprintf('MODEL has %g outputs, while LINCON is based on a model with %g outputs',nym,ny));
end
if num~=nu,
    error(sprintf('MODEL has %g inputs, while LINCON is based on a model with %g inputs',num,nu));
end
A=model.A;
B=model.B;

if tracking,
    sp=refs.y;
else
    sp=[];
end

% Initialize 
XX=[];
UU=[];

Ttot=Tstop/Ts;
TT=0:Ttot-1;

RR=sp;
x=x0(:); % Initial state (not including initial input u(-1) in case of lintracking)
u=u0(:);

for t=TT,
    XX=[XX;x'];
    if tracking,
        r=RR(t+1,:)';
        vec=eval(lincon,x,r,u,qpsolver,verbose);
        u=u+vec;
    else
        u=eval(lincon,x,[],u,qpsolver,verbose);
    end
    
    %disp(sprintf('t=%d, Region #%d',t,i));
    %if t/10==round(t/10),
    %   disp(sprintf('t=%d',t));
    %end
    
    if verbose,
        fprintf('t=%3d | ',t);
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
end
YY=XX*model.C'+UU*model.D';
if verbose,
    fprintf('\n\n');
end
%XX1=XX;
%UU1=UU;

TT=TT*Ts; % time vector in actual time units

if nargout==0,
    h=gcf;
    clf;
    set(h,'position',[246   258   521   358],'userdata','SIM');
    
    subplot(211)
    if tracking,
        for i=1:ny,
            plot(TT,YY(:,i),TT,RR(:,i));
            %stairs(TT,YY);
            hold on
            %stairs(TT,RR);
        end
        hold off
        grid
        title('output y(t), reference r(t)')
    else
        for i=1:nx,
            plot(TT,XX(:,i));
            %stairs(TT,XX(:,i));
            hold on
        end
        hold off
        grid
        %plot(TT,XX);
        title('state x(t)')
    end
    
    subplot(212)
    for i=1:nu,
        stairs(TT,UU(:,i));
        hold on
    end
    hold on
    grid
    hold off
    title('input u(t)')
end