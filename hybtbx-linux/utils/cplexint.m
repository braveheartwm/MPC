% 
%     CPLEXINT      MATLAB MEX INTERFACE FOR CPLEX
%     Copyright (C) 2001-2005  Mato Baotic
% 
%     This library is free software; you can redistribute it and/or
%     modify it under the terms of the GNU Lesser General Public
%     License as published by the Free Software Foundation; either
%     version 2.1 of the License, or (at your option) any later version.
% 
%     This library is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%     Lesser General Public License for more details.
% 
%     You should have received a copy of the GNU Lesser General Public
%     License along with this library; if not, write to the Free Software
%     Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
% 
%     Mato Baotic
%     Faculty of Electrical Engineering and Computing
%     Unska 3,
%     HR-10000 Zagreb
%     Croatia
%     mailto: mato.baotic@fer.hr
% 
% 
% Matlab MEX interface for CPLEX solver for the following optimization problem
% 
%    min    0.5*x'*H*x + f'*x
%     x
%    s.t.:  A x {'<=' | '='} b
%           x' * QC(i).Q * x + QC(i).L * x <= QC(i).r,  i=1,...,nQC
%           x >= LB
%           x <= UB
%           x(i) is of VARTYPE(i), i=1,...,n
% 
% The calling syntax is:
% [XMIN,FMIN,SOLSTAT,DETAILS] = cplexint(H, f, A, b, INDEQ, QC, LB, UB,...
%                                        VARTYPE, PARAM, OPTIONS)
% 
% 
% H          An (n x n) SYMETRIC, POSITIVE SEMIDEFINITE matrix (in full or sparse
%            format) containing the quadratic objective function coefficients.
%            Default: [], (no quadratic cost).
%
% f          An (n x 1) vector containing the linear objective function coefficients.
%            REQUIRED INPUT ARGUMENT.
% 
% A          An (m x n) matrix (in full or sparse format) containing the constraint
%            coefficients. REQUIRED INPUT ARGUMENT.
% 
% b          An (m x 1) vector containing the right-hand side value for each
%            constraint in the constraint matrix. REQUIRED INPUT ARGUMENT.
% 
% INDEQ      A vector containing the indices of equality constraints, i.e.,
%               A(INDEQ,:) x = B(INDEQ,:).
%            Default: [], (no equality constraints).
% 
% QC         A structure array containing Quadratic Constraints of the type
%               x' * QC(i).Q * x + QC(i).L * x <= QC(i).r, i=1,...,nQC,
%            where nQC=length(QC) is the total number of quadratic constraints.
%   QC(i).Q     - An (n x n) POSITIVE SEMIDEFINITE matrix (in full or sparse format),
%                 quadratic part of the quadratic contraint i.
%   QC(i).L     - A (1 x n) vector, linear part of the quadratic constraint i.
%   QC(i).r     - A scalar, right hand side of the quadratic constraint i.
%            Default: [], (no quadratic constraints).
%
%            NOTE: Contrary to the expressions for the objective function, in
%            quadratic constraints we do not multiply quadratic term with 0.5.
%            Also note that QC(i).L is a row vector. 
%
% LB         An (n x 1) vector containing the lower bound on each of the variables.
%            Any lower bound that is set to a value less than or equal to that of
%            the constant -CPX_INFBOUND will be treated as negative \infty.
%            CPX_INFBOUND is defined in the header file cplex.h.
%            Default: [], (lower bound of all variables set to -CPX_INFBOUND).
% 
% UB         An (n x 1) vector containing the upper bound on each of the variables.
%            Any upper bound that is set to a value greater than or equal to that of
%            the constant CPX_INFBOUND will be treated as \infty.
%            CPX_INFBOUND is defined in the header file cplex.h.
%            Default: [], (upper bound of all variables set to CPX_INFBOUND).
% 
% VARTYPE    An (n x 1) vector containing the types of the variables
%            VARTYPE(i) = 'C' Continuous variable
%            VARTYPE(i) = 'B' Binary(0/1) variable
%            VARTYPE(i) = 'I' Integer variable
%            VARTYPE(i) = 'S' Semi-continuous variable
%            VARTYPE(i) = 'N' Semi-integer variable
%            (This is case sensitive).
%            Default: [], (all variables are continuous).
% 
% PARAM      A structure with user specified (i.e., non-default) CPLEX parameters.
%   PARAM.int     - Set parameters of the type INT, (nintpar x 2) matrix,
%                   in the first column is CPLEX code, and in the second
%                   column is value of the parameter. For the correct code
%                   parameter values check ILOG CPLEX 9.0 Reference Manual 
%   PARAM.double  - Set parameters of the type DOUBLE, (ndoublepar x 2) matrix,
%                   in the first column is CPLEX code, and in the second
%                   column is value of the parameter. For the correct code
%                   parameter values check ILOG CPLEX 9.0 Reference Manual
%            Example:
%                By default CPLEX90 invokes Presolver to simplify and reduce
%                problems. If you want to switch off presolver you should use:
%                   OPTIONS.int=[1030, x]; 
%                with  x one of the following values:
%                0 [CPX_OFF] Off (do not use presolve) 
%                1 [CPX_ON] On (use presolve, default value) 
%                (1030 is CPLEX90 code for CPX_PARAM_PREIND, see Ref.Manual)
% 
% OPTIONS    Structure. More specific, advanced features.
%   verbose      Verbosity level:
%                   0 = be silent,
%                   1 = display only critical messages.
%                   2 = display everything. Note that in this case problem is also saved
%                       to an auxilary verbosity file "cplexint_verbose.lp".
%                Default: [] or 0, (be silent).
%            
%   save_prob    Name AND format of a file to which optimization problem should
%                be saved. Allowed formats are:
%                   'sav' - Binary matrix and basis file, 
%                   'mps' - MPS format,
%                   'lp'  - CPLEX LP format,
%                   'REW' - REW MPS format, with all names changed to generic names,
%                   'RMP' - MPS format, with all names changed to generic names,
%                   'RLP' - LP format, with all names changed to generic names
%                Example: OPTIONS.save_prob = 'cplexint_prob.lp'.
%                Default: [] or '', (don't save the problem).
%
%   logfile      Create a log file 'cplexint_logfile.log' to which internal CPLEX messages
%                will be saved: 0 = no, 1 = yes.
%                Default: [] or 0, (don't create the log file).
%
%   x0           An (nx0 by 2) matrix containing an initial guess for XMIN.
%                First column contains the indices of the variables for which
%                initial guess is provided, while the second column contains
%                the values. 
%                Default: [], (no initial guess).
%
%                NOTE: CPLEX uses x0 as an initial guess only for the MIP problems
%                (i.e., for MILP, MIQP, QCMILP and QCMIQP) while it has no effect
%                on the non-integer problems.
%
%   probtype     An integer between 0 and 7 through which user can specify (override)
%                problem type that CPLEXINT would normaly deduce from the input data:
%                0 - LP, 1 - QP, 2 - MILP, 3 - MIQP, 4 - QCLP, 5 - QCQP, 
%                6 - QCMILP, 7 - QCMIQP.
%                Default: [] or -1, (let CPLEXINT decide the problem type automatically).
%
%                NOTE: Although with this option user can easily specify problem type
%                and/or relax the original problem, we recommned using automatic
%                setting where CPLEXINT decides what is the problem type based on the
%                input data.
%                NOTE: The numbers CPLEXINT uses for describing the problem types differ
%                from the values CPLEX returns with a library function CPXgetprobtype
%                (see Ref.Manual for more details).
%
%   lic_rel      An integer through which user can specify after how many calls will
%                CPLEX environment be closed (and CPLEX license released).
%                Default: [] or 1, (close CPLEX environment after every call to CPLEXINT,
%                and therefore release the CPLEX license immediately after every call).
%
%                NOTE: This options allows users to "speed-up" exectution of a code
%                that consists of many calls to the CPLEX, esspecially when problems
%                are of small size and/or CPLEX license server is accessed through the net. 
%                WARNING: If number of calls to CPLEXINT is not integer multiple of
%                OPTIONS.lic_rel then CPLEX license is not released until user executes
%                "clear cplexint" command (or "clear mex" or "clear all") or exits Matlab.
%
%
% XMIN       The optimizer if computation is successfull (see SOLSTAT), otherwise
%            zero vector of size (n x 1). REQUIRED OUTPUT ARGUMENT.
% 
% FMIN       The optimum if computation is successfull (see SOLSTAT), otherwise
%            zero. REQUIRED OUTPUT ARGUMENT.
% 
% SOLSTAT    CPLEX code of a solution status. Interpretation of a number returned
%            here is given in CPX_STAT macros of CPLEX (see Reference Manual). The
%            corresponding CPX_STAT string can be accessed through DETAILS. If CPLEX
%            fails before running optimization or during optimization SOLSTAT = 0.
%            REQUIRED OUTPUT ARGUMENT.
%
%            NOTE: you should always check SOLSTAT to confirm that XMIN and FMIN
%            returned by CPLEXINT indeed represent an optimal solution.
%            Short string describing quality of the solution is available through
%            DETAILS.statstring.
% 
% DETAILS    Structure with more details about the solution. Number of details
%            depends on the problem being solved (as specified in brackets).
%
%   statstring  Short string explaining quality of the solution, (all problems)
%   solnmethod  More info in CPXsolninfo CPLEX Ref. manual, (LP, QP, QCLP, QCQP)
%   solntype    More info in CPXsolninfo CPLEX Ref. manual, (LP, QP, QCLP, QCQP)
%   pfeasind    More info in CPXsolninfo CPLEX Ref. manual, (LP, QP, QCLP, QCQP)
%   dfeasind    More info in CPXsolninfo CPLEX Ref. manual, (LP, QP, QCLP, QCQP)
%   lpsolved    The number of LP solved, (MILP, MIQP, QCMILP, QCMIQP)
%   dual        Dual variables, (LP, QP)
%   slack       Slack variables, (all problems)
%   qcslack     Quadratic constraint slacks, (QCLP, QCQP, QCMILP, QCMIQP)
%   redcost     Reduced cost, (LP, QP)
%
%           NOTE: If CPLEXINT fails to get any of expected DETAILS fields an error
%           message will be displayed if OPTIONS.verbose >=1, but execution of the
%           mex file will not be interrupted.
%
% KNOWN BUGS
% 
% If you press CTRC-C to interrupt CPLEX computations, CPLEX may not release 
% the license. This issue is currently under investigation to be solved.
% When this happens just wait that the license manager realizes CPLEX has 
% timed out.
% 
% THIS IS BETA SOFTWARE
%
% Contact:  Mato Baotic
%           Faculty of Electrical Engineering and Computing
%           Unska 3,
%           HR-10000 Zagreb
%           Croatia
%           mato.baotic@fer.hr
%
%
% History: date: yyyy.mm.dd | subject | (author)
% ----------------------------------------------
% 2005.09.24  Fixed memory leak when clearing CPXenv,
%             Allow sparse matrix entries for quadratic constraints, (Mato)
%             ver.2.3
% 2005.09.21  Fix: mexErrMsgTxt() problems with R14 Matlab on Linux,
%                  VARTYPE allocation, (Mato: thanks to Michal Kvasnica) 
%             ver.2.2
% 2004.06.03  Clean up of the code, (Mato)
%             ver.2.1
% 2004.05.17  Initial relase, (Mato)
%             ver.2.0
