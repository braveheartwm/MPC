%  MILPSOL Solve mixed-integer linear programming problems using a specified solver.
% 
%     X=MILPSOL(f,A,b,ivar) solves the mixed integer linear programming problem:
%           
%               min f'x    subject to:   Ax <= b, x(ivar)={0,1} 
%                x
%      
%      X=MILPSOL(f,A,b,ivar,solver) indicates which MILP solver 
%      should be used
%          solver=0:  uses MIQP3_NAF.M + E04MBF
%          solver=1:  uses MIQP.M + LP.M
%          solver=2:  uses CPLEX by Ilog (thanks to N. Giorgetti)
%          solver=21: uses CPLEX by Ilog (using M. Baotic's interface)
%          solver=22: uses CPLEX (using IBM ILOG Matlab interface)
%          solver=3:  uses GLPK, Revised Simplex Method (default) (thanks to N. Giorgetti)
%          solver=5:  uses MIQP.M + LINPROG
%          solver=6:  uses Xpress-MP by Dash Optimization  (thanks to N. Giorgetti)
%          solver=8:  uses GUROBI
%          solver=4:  uses INTLINPROG from Optimization Toolbox
% 
%      You can choose the solver using function MILPTYPE.
% 
%      X=MILPSOL(f,A,b,ivar,solver,VLB,VUB) defines a set of lower and upper
%      bounds on the design variables, X, so that the solution is always in
%      the range VLB <= X <= VUB.
%   
%      X=MILPSOL(f,A,b,ivar,solver,VLB,VUB,X0) sets the initial starting point at X0.
% 
%      X=MILPSOL(f,A,b,ivar,solver,VLB,VUB,X0,DISPLAY) sets the verbosity level
%      of the optimizer.
% 
%      X=MILPSOL(f,A,b,ivar,solver,VLB,VUB,X0,DISPLAY,TILIM) sets the time limit
%      to TILIM seconds. The best solution found is returned in case the
%      solver stops because of the time limit (GLPK, CPLEX, and GUROBI only)
% 
%      X=MILPSOL(f,A,b,ivar,solver,VLB,VUB,X0,DISPLAY,TILIM,N) indicates that 
%      the first N constraints defined by A and b are equality constraints.
% 
%      [X,FLAG] = MILPSOL(f,A,b,ivar) also returns the exit flag FLAG:
%          FLAG = 1          optimal solution found
%          FLAG = 2          time limit exceeded, integer solution found (GLPK and CPLEX only)
%          FLAG = -2         time limit exceeded, no integer solution (GLPK and CPLEX only)
% 
%      [X,FLAG,FMIN] = MILPSOL(f,A,b,ivar,...) also returns the optimal
%      value fmin
% 
%  See also MILPTYPE, MIQPSOL, MIQPTYPE
% 
% (C) 2003-2011 by A. Bemporad
