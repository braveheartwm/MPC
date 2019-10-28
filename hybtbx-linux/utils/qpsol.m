%  QPSOL Solve quadratic programming problems using a specified QP solver
% 
%  [xopt,lambda,how]=qpsol(Q,f,A,b,VLB,VUB,x0,solver,invQ,display,N) solve a QP problem.
% 
%     X=QPSOL(Q,f,A,b) solves the quadratic programming problem:
% 
%               min .5*x'Qx+f'x    subject to:   Ax <= b
%                x
% 
%     X=QPSOL(Q,f,A,b,VLB,VUB) defines a set of lower and upper
%     bounds on the design variables, X, so that the solution is always in
%     the range VLB <= X <= VUB.
% 
%     X=QPSOL(Q,f,A,b,VLB,VUB,x0) sets the initial starting point at x0.
% 
%     X=QPSOL(Q,f,A,b,VLB,VUB,x0,solver) indicates which QP solver should be used
%          solver=0:  uses E04NAF or E04NF (depending on NAG toolbox version)
%          solver=1:  uses QP.M
%          solver=2:  uses Ilog CPLEX (thanks to N. Giorgetti)
%          solver=21: uses CPLEX by Ilog (using M. Baotic's interface)
%          solver=22: uses IBM CPLEX (thanks to Davide Barcelli)
%          solver=4:  uses QPACT
%          solver=5:  uses QUADPROG
%          solver=6:  uses Dash Optimization Xpress-MP (thanks to N. Giorgetti)
%          solver=7:  uses MEXCLP (by Johan Lofberg)
%          solver=8:  uses GUROBI
%          solver=9:  uses QPKWIK from MPC Toolbox
%          solver=91: uses QPKWIK from MPC Toolbox, new version supporting equality constraints
% 
%     X=QPSOL(Q,f,A,b,VLB,VUB,x0,solver,Qinv) also provides the inverse Qinv=inv(Q)
%     (only needed by QPACT, QPKWIK)
% 
%     X=QPSOL(Q,f,A,b,VLB,VUB,x0,solver,Qinv,display) controls the level of messages displayed.
%     Messages can be turned off with DISPLAY = -1.
% 
%     X=QPSOL(Q,f,A,b,VLB,VUB,x0,solver,Qinv,display,N) impose the equality
%     constraints A(1:N,:)*x==b(1:N) (default: N=0)
% 
%     [X,LAMBDA]=QPSOL(Q,f,A,b,...) returns the set of Lagrangian multipliers,
%     LAMBDA at the solution.
% 
%     [X,LAMBDA,HOW] = QPSOL(Q,f,A,b,...) also returns a string HOW that indicates
%     error conditions at the final iteration.
%          HOW = 'ok'           optimal solution found
%          HOW = 'infeasible'   no feasible solution found
%          HOW = 'unbounded'    solution is unbounded
%          HOW = 'unreliable'   solution is unreliable
% 
% (C) 2003-2017 by A. Bemporad
