%  LPSOL Solve linear programming problems using a specified LP solver.
%  The syntax is the same as LP.M:
% 
%     X=LPSOL(f,A,b) solves the linear programming problem:
% 
%               min f'x    subject to:   Ax <= b
%                x
% 
%      X=LPSOL(f,A,b,VLB,VUB) defines a set of lower and upper
%      bounds on the design variables, X, so that the solution is always in
%      the range VLB <= X <= VUB.
% 
%      X=LPSOL(f,A,b,VLB,VUB,X0) sets the initial starting point at X0.
% 
%      X=LPSOL(f,A,b,VLB,VUB,X0,N) indicates that the first N constraints defined
%      by A and b are equality constraints.
% 
%      X=LPSOL(f,A,b,VLB,VUB,X0,N,DISPLAY) controls the level of messages displayed.
%      Warning messages can be turned off with DISPLAY = -1.
% 
%      X=LPSOL(f,A,b,VLB,VUB,X0,N,DISPLAY,SOLVER) indicates which LP solver
%      should be used
%          solver=0:  uses E04MBF or E04MF (depending on NAG version)
%          solver=1:  uses LP.M
%          solver=2:  uses CPLEX (thanks to N. Giorgetti)
%          solver=21: uses CPLEX by Ilog (using M. Baotic's interface)
%          solver=22: uses IBM CLPEX interface (thanks to Davide Barcelli)
%          solver=3:  uses GLPK, Revised Simplex Method (default) (thanks to N. Giorgetti)
%          solver=4:  uses QPACT
%          solver=5:  uses LINPROG
%          solver=6:  uses Dash Optimization Xpress-MP (thanks to N. Giorgetti)
%          solver=7:  uses CDD by K. Fukuda (interface updated by S. Di Cairano)
%          solver=8:  uses GUROBI
%          solver=9:  uses INTLINPROG
% 
%      [x,LAMBDA]=LPSOL(f,A,b) returns the set of Lagrangian multipliers
%      LAMBDA at the solution.
% 
%      [X,LAMBDA,HOW] = LPSOL(f,A,b) also returns the string HOW that indicates
%      error conditions at the final iteration:
%          HOW = 'ok'           optimal solution found
%          HOW = 'infeasible'   no feasible solution found
%          HOW = 'unbounded'    solution is unbounded
% 
% (C) 2003-2015 by A. Bemporad
