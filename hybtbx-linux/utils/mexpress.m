% MEXPRESS MEX Interface for the Xpress Optimizer
%
% Copyright (C) 2004, Nicolo' Giorgetti, 
% Department of Information Engineering, University of Siena, 
% Siena, Italy. All rights reserved. 
% E-mail: <giorgetti@dii.unisi.it>.
% 
% This file is part of MEXPRESS.
% 
% MEXPRESS is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2, or (at your option)
% any later version.
% 
% MEXPRESS is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
% or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
% License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with GLPK; see the file COPYING. If not, write to the Free
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
%
% The calling syntax is:
% [XOPT,OPT,STATUS,EXTRA] = mexpress(SENSE,H,F,...
%                                     A,B,CTYPE,LB,UB,...
%                                     VARTYPE,PARAMS,SAVE)
%
% Tip: type just mexpress to have a quick reference on the input and output
% fields.
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
% PARAMS     A structure containing some parameters used to define
%            the behavior of solver. For more details type
%            HELP MEXPRESSPARAMS.
%
% SAVE       Saves a copy of the problem if SAVE<>0.
%            The file name can not be specified and defaults to "outpb.lp".
%
%
%
% XOPT       The optimizer.
%
% STATUS     Status of the optimization.
%            
%               --- LP/QP problem ---
%                   1  Optimal.
%                   2  Infeasible.
%                   3  Objective worse than cutoff.
%                   4  Unfinished.
%                   5  Unbounded.
%                   6  Cutoff in dual.
%
%               --- MILP/MIQP problem ---
%                   0  Problem has not been loaded.
%                   1  LP has not been optimized.
%                   2  LP has been optimized. Once the MIP optimization 
%                      proper has begun,  only the following four status codes
%                      will be returned.
%                   3  Global search incomplete no integer solution found.
%                   4  Global search incomplete an integer solution has been found.
%                   5  Global search complete no integer solution found.
%                   6  Global search complete integer solution found.
%
% OPT        The optimum.
%                 
%
% EXTRA      A data structure containing two fields:
%            LAMBDA     Dual variables.	
%            RC         Reduced costs.
%            SLACK      Slack variables.
%


