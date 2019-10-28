%  MIQPSOL Solve mixed-integer quadratic programming problems using a specified solver.
% 
%     X=MIQPSOL(H,f,A,b,ivar) solves the mixed integer quadratic programming problem:
% 
%               min 0.5*x'Hx+f'x    subject to:   Ax <= b, x(ivar)={0,1}
%                x
% 
%      X=MIQPSOL(H,f,A,b,ivar,solver) indicates which MIQP solver
%      should be used
%          solver=0:  uses MIQP.M + QUADPROG.M
%          solver=1:  uses NAG (MIQP.M + E04NAF or E04NF)
%          solver=3:  uses CPLEX (thanks to N. Giorgetti)
%          solver=31: uses CPLEX (using M. Baotic's interface)
%          solver=32: uses CPLEX (using IBM ILOG Matlab interface)
%          solver=6:  uses XPRESS-MP by Dash Optimization (thanks to N. Giorgetti)
%          solver=7:  uses MIQP.M + MEXCLP.DLL (thanks to J. Lofberg)
%          solver=8:  uses GUROBI
%      You can choose the solver using function MIQPTYPE.
% 
%      X=MIQPSOL(H,f,A,b,ivar,solver,VLB,VUB) defines a set of lower and upper
%      bounds on the design variables, X, so that the solution is always in
%      the range VLB <= X <= VUB.
% 
%      X=MIQPSOL(H,f,A,b,ivar,solver,VLB,VUB,X0) sets the initial starting point at X0.
% 
%      X=MIQPSOL(H,f,A,b,ivar,solver,VLB,VUB,X0,DISPLAY) sets the verbosity level
%      of the optimizer.
% 
%      X=MILPSOL(H,f,A,b,ivar,solver,VLB,VUB,X0,DISPLAY,TILIM) sets the time limit
%      to TILIM seconds. The best solution found is returned in case the
%      solver stops because of the time limit (CPLEX and GUROBI only)
% 
%      X=MILPSOL(H,f,A,b,ivar,solver,VLB,VUB,X0,DISPLAY,TILIM,N) treat the
%      first N constraints as equality constraints.
% 
%      [X,FLAG] = MIQPSOL(H,f,A,b,ivar) also returns the exit flag FLAG:
%          FLAG = 1          optimal solution found
%          FLAG = 2          time limit exceeded, integer solution found (CPLEX only)
%          FLAG = -2         time limit exceeded, no integer solution (CPLEX only)
% 
%      [X,FLAG,FMIN] = MIQPSOL(H,f,A,b,ivar,...) also returns the optimal value fmin
% 
%  See also MIQPTYPE, MILPSOL, MILPTYPE
% 
% (C) 2004-2017 by A. Bemporad
