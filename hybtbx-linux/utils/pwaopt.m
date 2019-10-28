%  PWAOPT Solve discrete-time hybrid finite-time optimal control in explicit form. 
%  The solution method is based on feasible mode enumeration and
%  (1) mpLP, and comparison of convex PWA functions for Inf-norms, or
%  (2) mpQP for 2-norms
% 
%  [sol,lpsolved,colors]=pwaopt(P,T,setup)
% 
%  setup is a structure with fields:
%     .Qc   = weight matrix on continuous states,
%     .Rc   = weight matrix on continuous inputs
%     .Yc   = weight matrix on continuous outputs,
%     .Qb   = weight matrix on binary states
%     .Rb   = weight matrix on binary inputs
%     .Yb   = weight matrix on binary outputs
%     .ymin  = lower bounds on continuous outputs
%     .ymax  = upper bounds on continuous outputs
%     .xmin  = lower bounds on continuous states
%     .xmax  = upper bounds on continuous states
%     .umin  = lower bounds on continuous inputs
%     .umax  = upper bounds on continuous inputs
%     .Pc    = weight on terminal continuous states
%     .Pb    = weight on terminal binary states
%     .rho   = weight on slack variable
%     .Sx    = terminal constraint on continuous states (Sx*x<=Tx)
%     .Tx
%     .norm  = norm used (either '2' or 'Inf') 
% 
%     .x0min = range of initial states where the mp-problem is solved
%     .x0max =   " 
%     .y0refmin = range of output references where the mp-problem is solved
%     .y0refmax =   " 
%     .x0refmin = range of state references where the mp-problem is solved
%     .x0refmax =   " 
%     .u0refmin = range of input references where the mp-problem is solved
%     .u0refmax =   "
% 
%     .LPsolver = LP solver used (see LPTYPE)
%     .verbose  = verbosity level
%     .mplpverbose  = verbosity level of mpLP solver
%     .mpqpverbose  = verbosity level of mpQP solver
% 
%     .norefs     =1 assign state and input references to setup.xrc, setup.urc
%     .noslack    =1 hard constraints
%     .flattol    Tolerance for a set to be considered flat
%     .waitbar    display waitbar
% 
%     .refsignals = structure with fields x,u. 
% 
%  Example: refsignals.x=[1,3] means that references are only given for states 1,3 (see HYBCON)
% 
%     .fixref, .valueref = structures with fields y,x,u
% 
%  Example: to fix the reference signal for x(1),x(2) at the values
%  rx(1)=0.6, rx(2)=-1.4 and mantain the reference rx(3) for x(3) as a free
%  parameter, specify options.fixref.x=[1 2], options.valueref.x=[0.6 -1.4].
% 
%  Note: references for the binary output, state, and input vectors must be fixed
%  (to avoid solving parametrically with respect to the **relaxation** of 
%  such references)
% 
%  (C) 2003-2004 by A. Bemporad
