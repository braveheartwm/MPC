function solver=miqptype(miqpsolver)
% MIQPTYPE Convert MIQP solver string to number. 
%
% SOLVER=MIQPTYPE(STRING) where STRING is one of the following supported 
% MIQP solvers:
%
% 'miqp'      MIQP.M using QP solver QUADPROG.M from Optimization Toolbox
% 'nag'       MIQP.M using QP solver from NAG Foundation Toolbox
% 'qpact'     MIQP.M using QP solver QPACT
% 'cplex'     Ilog CPLEX (thanks to N. Giorgetti)
% 'cplexint'  Ilog CPLEX (use M. Baotic's interface)
% 'cplex_ibm' IBM CPLEX (use IBM interface to MATLAB)
% 'xpress'    Dash Optimization Xpress-MP (thanks to N. Giorgetti)
% 'gurobi'    GUROBI 
%
% See also MIQPSOL, MILPSOL, MILPTYPE, QPSOL, QPTYPE, LPSOL, LPTYPE

%(C) 2004-2012 by A. Bemporad

if nargin < 1 || isempty(miqpsolver),
        miqpsolver='qpact'; % Use MIQP.M + QPACT by default
end

switch miqpsolver
    case 'miqp'
        solver=0;
    case 'nag'
        solver=1;
    case 'cplex'    % Thanks to N. Giorgetti
        solver=3;
    case 'cplexint'
        solver=31; % (thanks to M. Baotic)
    case 'cplex_ibm'
        solver=32; % New IBM-ILOG Matlab interface (available since Cplex 12.x)
    case 'qpact'
        solver=4;
    case 'xpress'   % Thanks to N. Giorgetti
        solver=6;
    case 'clp'      % Thanks to J. Lofberg
        solver=7;
    case 'gurobi'   % Thanks to Wotao Yin's mex interface
        solver=8;
    case 'miqp_admm'
        solver=9;
    case 'miqpnnls_ldl'
        solver=91;
    case 'miqpnnls_qr'
        solver=92;
    case 'miqpgpad'
        solver=93;
    case 'miqpnnls_prox'
        solver=94;
    case 'submiqp_test'
        solver=95;
    otherwise
        error('unknown MIQP solver');
end
