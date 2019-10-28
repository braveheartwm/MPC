% CPLEXMEX MEX Interface for the CPLEX Callable Library
%
% Copyright (C) 2004, Nicolo' Giorgetti, 
% Department of Information Engineering, University of Siena, 
% Siena, Italy. All rights reserved. 
% E-mail: <giorgetti@dii.unisi.it>.
% 
% This file is part of CPLEXMEX.
% 
% CPLEXMEX is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2, or (at your option)
% any later version.
% 
% CPLEXMEX is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
% or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
% License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with CPLEXMEX; see the file COPYING. If not, write to the Free
% Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
% 02111-1307, USA.
%
% This routine calls the Xpress library to solve a LP/MILP/QP/MIQP problem. A typical
% MIP problem has following structure:
%
%        min|max	0.5 y'Hy + f'y
%           y
%        s. to		A*y [<=|==|>=] b
%   			    lb <= y <= ub
%        where
%     			    y in R^{n_c}x{0,1}^{n_d}
%   			    y(ivar) in {0,1}^{n_d}
%
%        and an initial condition x=x0.
%
%
% The calling syntax is:
% [XOPT,OPT,STATUS,EXTRA] = mexpress(SENSE,H,F,...
%                                     A,B,CTYPE,LB,UB,...
%                                     VARTYPE,X0,PARAMS,SAVE)
%
% For a quick syntax reference just type mexpress at the command line.
%
% SENSE:     indicates whether the problem is a minimization
%            or maximization problem.
%            SENSE = 1 minimize
%            SENSE = -1 maximize.
%
% H:         A column array containing the quadratic objective function
%            coefficients.
%
% F:         A column array containing the linear objective function
%            coefficients.
%
% A:         A matrix containing the constraints coefficients. A
%            may be a sparse matrix (see 'help sparse' in matlab,
%            for details).
%
% B:         A column array containing the right-hand side value for
%            each constraint in the constraint matrix.
%
% CTYPE      A column array containing the sense of each constraint
%            in the constraint matrix.
%            CTYPE(i) = 'L'  "<=" Variable with upper bound
%            CTYPE(i) = 'E'  "="  Fixed Variable
%            CTYPE(i) = 'G'  ">=" Variable with lower bound
%            CTYPE(i) = 'N'  Nonbinding constraint
%            (This is case sensitive).
%            By default ([] empty array) sense are upper bounded.
%
% LB         An array of at least length numcols containing the lower
%            bound on each of the variables. If the i-th variable is
%            lower bounded free put lb(i)=-Inf. If all variables are lower
%            bounded free put lb=-Inf*ones(number_of_columns,1) or more
%            simply lb=[];
%
% UB         An array of at least length numcols containing the upper
%            bound on each of the variables. If the i-th variable is
%            upper bounded free put ub(i)=Inf. If all variables are upper 
%            bounded free put ub=Inf*ones(number_of_columns,1) or more
%            simply ub=[];
%
% VARTYPE    A column array containing the types of the variables.
%            VARTYPE(i) = 'C' continuous variable
%            VARTYPE(i) = 'I' Integer variable
%            VARTYPE(i) = 'B' Boolean variable 
%            (This is case sensitive).
%
% X0         A column vector containing the initial condition of MILP/MIQP 
%            problem types. To leave free a value just put a Inf value in
%            the corresponding value
%
% PARAMS     A structure containing some parameters used to define
%            the behavior of solver. For more details type
%            HELP CPLEXMEXPARAMS.
%
% SAVE       Saves a copy of the problem if SAVE<>0.
%            The file name can not be specified and defaults to "cplexpb.lp".
%
%
%
% XOPT       The optimizer.
%
% OPT        The optimum.              
%
% STATUS     Status of the optimization.
%            
%            --- LP/QP problem ---
%
%            (Simplex or Barrier)
%            1   Optimal solution is available.
%            2   Model has an Unbounded ray.
%            3   Model has been proved infeasible.
%            4   Model has been proved either infeasible or unbounded.
%            5   Optimal solution is available, but with infeasibilities 
%                 after unscaling.
%            6   Solution is available, but not proved optimal,  
%                 due to numeric difficulties during optimization.
%            10  Stopped due to limit on number of iterations.
%            11  Stopped due to a time limit.
%            12  Stopped due to an objective limit.     
%            13  Stopped due to a request from the user.
%
%            (Barrier only) 
%            20  Model has an unbounded optimal face.
%            21  Stopped due to a limit on the primal objective.
%            22  Stopped due to a limit on the dual objective.
%            
%
%            --- MILP/MIQP problem ---
%
%            101 Optimal integer solution has been found
%            102 Optimal soluton with the tolerance defined by epgap or 
%                 epagap has been found
%            103 Solution is integer infeasible 
%            104 The limit on mixed integer solutions has been reached 
%            105 Node limit has been exceeded but integer solution exists
%            106 Node limit has been reached; no integer solution
%            107 Time limit exceeded, but integer solution exists
%            108 Time limit exceeded; no integer solution
%            109 Terminated because of an error, but integer solution exists
%            110 Terminated because of an error; no integer solution 
%            111 Limit on tree memory has been reached, but an integer solution 
%                 exists
%            112 Limit on tree memory has been reached; no integer solution
%            113 Stopped, but an integer solution exists
%            114 Stopped; no integer solution
%            115 Problem is optimal with unscaled infeasibilities
%            116 Out of memory, no tree available, integer solution exists
%            117 Out of memory, no tree available, no integer solution
%            118 Model has an unbounded ray 
%            119 Model has been proved either infeasible or unbounded 
%
% EXTRA      A data structure containing two fields:
%              LAMBDA     Dual variables of the problem.
%              RC         Reduced Costs.



