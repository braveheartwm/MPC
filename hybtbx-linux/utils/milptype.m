function solver=milptype(milpsolver)
% MILPTYPE Convert MILP solver string to number
%
% SOLVER=MILPTYPE(STRING) where STRING is one of the following supported
% MILP solvers:
%
% 'glpk'       GNU Linear Programming Kit, Revised Simplex Method (default) (thanks to N. Giorgetti)
% 'intlinprog' MILP solver INTLINPROG from Optimization Toolbox
% 'cplex'      Ilog CPLEX (thanks to N. Giorgetti)
% 'cplexint'   Ilog CPLEX (use M. Baotic's interface)
% 'cplex_ibm'  IBM CPLEX (use IBM interface to MATLAB)
% 'xpress'     Dash Optimization Xpress-MP (thanks to N. Giorgetti)
% 'nag'        MIQP.M using LP solver from NAG Foundation Toolbox
% 'matlab'     MIQP.M using LP solver LP.M from Optimization Toolbox
% 'linprog'    MIQP.M using LP solver LINPROG.M from Optimization Toolbox
% 'gurobi'     GUROBI
%
% See also MILPSOL, MIQPSOL, MIQPTYPE, LPSOL, LPTYPE, QPSOL, QPTYPE

%(C) 2003-2017 by A. Bemporad

%Type HELP MILPSOL for supported solvers

if nargin < 1 || isempty(milpsolver)
    milpsolver='glpk'; % Use GLPK by default
end

switch milpsolver
    case 'nag'
        solver=0;
    case 'matlab'
        solver=1;
    case 'cplex'
        solver=2;
    case 'cplexint'
        solver=21;
    case 'cplex_ibm'
        solver=22;
    case 'glpk'
        solver=3;
    case 'linprog'
        solver=5;
    case 'xpress'
        solver=6;
    case 'gurobi'   % Thanks to Wotao Yin's mex interface
        solver=8;
    case 'miqp_admm'
        solver=9;
    case 'intlinprog'
        solver=4;
    otherwise
        error('unknown MILP solver');
end
