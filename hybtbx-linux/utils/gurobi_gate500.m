%  GUROBI_GATE Solve (mixed-integer) linear or quadratic programming
%  problems using GUROBI 5.0.0
% 
%     [x,flag,fmin]=GUROBI_GATE500(H,f,A,b,ivar,vlb,vub,x0,display,tilim)
%     solves the optimization problem
% 
%               min_x        0.5*x'Hx+f'x    
%               subject to   Ax <= b, x(ivar)={0,1}
%                            vlb <= x <= vub
% 
%     [x,flag,fmin]=GUROBI_GATE(H,f,A,b,ivar,vlb,vub,x0,display,tilim,N)
%     indicates that the first N constraints defined by A and b are equality constraints.
% 
%     [x,flag,fmin,lambda]=GUROBI_GATE(H,f,A,b,[],vlb,vub,x0,display,tilim,N)
%     also returns the vector of Lagrange multipliers lambda (only for non-integer problems)
% 
%  Exit flag:
% 
%  0 = infeasible
%  1 = optimal solution found
%  2 = time limit exceeded
%  3 = unbounded
%  string = original Gurobi's Optimization Status Code (see http://gurobi.com/documentation/5.0/reference-manual/)
% 
%  (C) 2012 by A. Bemporad, May 4, 2012
