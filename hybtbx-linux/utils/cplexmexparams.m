% CPLEXMEX Parameters list 
%
% Copyright (C) 2001-2004, Nicolo' Giorgetti, 
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
% 
% This document describes all control parameters currently implemented 
% in the CPLEXMEX, a Matlab MEX interface for the CPLEX Callable Library. Symbolic 
% names of control parameters are given on the left. Types, default 
% values, and descriptions are given on the right. 
% 
% -----------------------
% 1 Integer parameters 
% -----------------------
%
% msglev       type: integer, default: 0
%              Level of messages output by solver routines: 
%                 0 no output [default]
%                 1 full output (includes informational messages) 
%
% errmsg       type: integer, default: 1
%              Error/Warning messages output by solver routines: 
%                 0 no output
%                 1 error/warning output [default]
%                
% presol	   type: int, default: 1
%              If this flag is set, the built-in presolver is used. 
%              Otherwise the LP/MIP presolver is not used. 
% 
% 
% -----------------------
% 2 Real parameters 
% -----------------------
%
% epgap        type: double, default: 1e-4
%              Relative mipgap tolerance. 
%              Sets a relative tolerance on the gap between the best 
%              integer objective and the objective of the best node remaining. 
%              When the value  |bestnode-bestinteger|/(le-10+|bestinteger|) falls 
%              below the value of the 'epagap' parameter, the mixed integer 
%              optimization is stopped. For example, to instruct CPLEX to stop as 
%              soon as it has found a feasible integer solution proved to be within 
%              five percent of optimal, set the relative epagap tolerance to .05 .  
%
% epagap       type: double, default 1e-6
%              Absolute mipgap tolerance. 
%              Sets an absolute tolerance on the gap between the best integer 
%              objective and the objective of the best node remaining. When this 
%              difference falls below the value of the ABSMIPGAP parameter, the mixed 
%              integer optimization is stopped. 
%
% relobjdif    type: double, default: 0.0 defined in [0, 1]
%              Relative objective difference cutoff. 
%              Used to update the cutoff each time a mixed integer solution is found. 
%              The value is multiplied by the absolute value of the integer objective 
%              and subtracted from (added to) the newly found integer objective when 
%              minimizing (maximizing). This forces the mixed integer optimization to 
%              ignore integer solutions that are not at least this amount better than 
%              the one found so far. The relative objective difference parameter can be
%              adjusted to improve problem solving efficiency by limiting the number 
%              of nodes; however, setting this parameter at a value other than zero 
%              (the default) can cause some integer solutions, including the true 
%              integer optimum, to be missed. 
% 
% objdif       type: double, default: 0.0 
%              Absolute objective difference cutoff. 
%              Used to update the cutoff each time a mixed integer solution is found. 
%              This absolute value is subtracted from (added to) the newly found 
%              integer objective value when minimizing (maximizing). This forces the 
%              mixed integer optimization to ignore integer solutions that are not at 
%              least this amount better than the one found so far. The OBJDIFFERENCE 
%              parameter can be adjusted to improve problem solving efficiency by 
%              limiting the number of nodes; however, setting this parameter at a 
%              value other than zero (the default) can cause some integer solutions, 
%              including the true integer optimum, to be missed. Negative values for 
%              this parameter can result in some integer solutions that are worse 
%              than or the same as those previously generated, but does not 
%              necessarily result in the generation of all possible integer solutions. 
%
% tilim        type: double. default: 1e75
%              Global time limit. 
%              Sets the maximum time, in seconds, for a call to an optimizer. This 
%              time limit applies also to the infeasibility finder. The time is 
%              measured in terms of either CPU time or elapsed time, according to the 
%              setting of the CLOCKTYPE parameter. The time limit for an optimizer 
%              applies to the sum of all its steps, such as preprocessing,crossover, 
%              and internal calls to other optimizers. In a sequence of calls to 
%              optimizers, the limit is not cumulative but applies to each call 
%              individually. For example, if you set a time limit of 10 seconds, and 
%              you call mipopt twice then there could be a total of (at most) 20 
%              seconds of running time if each call consumes its maximum allotment. 
 
