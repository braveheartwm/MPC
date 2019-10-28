function solver=qptype(qpsolver)
% QPTYPE Convert QP solver string to number. 
%
% SOLVER=QPTYPE(STRING) where STRING is one of the following supported QP solvers:
%
% 'nag'       NAG Foundation Toolbox - E04NAF or E04NF
% 'qp'        QP solver QP.M from Optimization Toolbox
% 'quadprog'  QUADPROG.M from Optimization Toolbox
% 'cplex'     Ilog CPLEX (thanks to N. Giorgetti)
% 'cplexint'  Ilog CPLEX (use M. Baotic's interface)
% 'cplex_ibm' IBM CPLEX (use IBM interface to MATLAB)
% 'xpress'    Dash Optimization Xpress-MP (thanks to N. Giorgetti)
% 'qpact'     QPACT.DLL
% 'clp'       MEXCLP.DLL (by Johan Lofberg)
% 'gurobi'    GUROBI
% 'qpkwik'    New QP solver of MPC Toolbox
% 'qpkwik2'   New QP solver of MPC Toolbox supporting equality constraints
%
% See also QPSOL, LPSOL, LPTYPE, MILPSOL, MILPTYPE, MIQPSOL, MIQPTYPE

%(C) 2004-2013 by A. Bemporad

if nargin < 1 || isempty(qpsolver),
    if exist('qpact'),
        qpsolver='qpact'; % Use QPACT.DLL by default
    elseif exist('e04naf') || exist('e04nf'),
        qpsolver='nag'; % Use E04NAF or E04NF by default
    elseif exist('qp'),
        qpsolver='qp'; % Use QP.M by default
    else
        error('No QP solver found.');
    end
else
    if strcmp(qpsolver,'nag') && ~exist('e04naf') && ~exist('e04nf'),
        warning('NAG Toolbox not found -- Switching to QPACT');
        qpsolver='qpact'; % Switch to QPACT
    end
end

switch qpsolver
    case 'nag'
        solver=0;
    case 'qp'
        solver=1;
    case 'cplex'
        solver=2;
    case 'cplexint'
        solver=21;
    case 'cplex_ibm'
        solver=22;
    case 'qpact'
        solver=4;
    case 'quadprog'
        solver=5;
    case 'xpress'
        solver=6;
    case 'clp'
        solver=7;
    case 'gurobi'   % Thanks to Wotao Yin's mex interface
        solver=8;
    case 'qpkwik'
        solver=9;
    case 'qpkwik2'
        solver=91;
    case 'qpng'
        solver=99;
    case 'qpnnls'
        solver=98;
    otherwise
        error('unknown QP solver');
end
