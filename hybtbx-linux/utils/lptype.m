function solver=lptype(lpsolver)
% LPTYPE Convert LP solver string to number. 
%
% SOLVER=LPTYPE(STRING) where STRING is one of the following supported LP solvers:
%
% 'glpk'      GNU Linear Programming Kit, Revised Simplex Method (default) (thanks to N. Giorgetti)
% 'cplex'     Ilog CPLEX (thanks to N. Giorgetti)
% 'cplexint'  Ilog CPLEX (use M. Baotic's interface)
% 'cplex_ibm' IBM CPLEX (use IBM interface to MATLAB)
% 'xpress'    Dash Optimization Xpress-MP (thanks to N. Giorgetti)
% 'nag'       NAG Foundation Toolbox - E04MBF.M or E04MF.M
% 'matlab'    LP solver LP.M from Optimization Toolbox
% 'linprog'   LINPROG.M from Optimization Toolbox
% 'qpact'     QPACT.DLL
% 'cdd'       CDD package by K. Fukuda
% 'gurobi'    GUROBI 
% 'intlinprog' INTLINPROG (R2014a)
%
% See also LPSOL, QPSOL, QPTYPE, MILPSOL, MILPTYPE, MIQPSOL, MIQPTYPE

%(C) 2004-2012 by A. Bemporad

if nargin < 1 || isempty(lpsolver),
    if exist('glpkmex'),
        lpsolver='glpk'; % Use GLPK by default
    elseif exist('e04mbf') || exist('e04mf'),
        lpsolver='nag'; % Use E04MBF.M by default
    elseif exist('lp'),
        lpsolver='lp'; % Use LP.M by default
    else
        error('No LP/QP solver found. Aborting');
    end
else
    if strcmp(lpsolver,'nag') && ~exist('e04mbf') && ~exist('e04mf'),
        warning('NAG Toolbox not found -- Switching to GLPK');
        lpsolver='glpk'; % Switch to GLPK
    end
end

switch lpsolver
    case 'nag'
        solver=0;
    case 'lp'
        solver=1;
    case 'cplex'
        solver=2;
    case 'cplexint'
        solver=21;
    case 'cplex_ibm'
        solver=22;
    case 'glpk'
        solver=3;
    case 'qpact'
        solver=4;
    case 'linprog'
        solver=5;
    case 'xpress'
        solver=6;
    case 'cdd'
        solver=7;
    case 'gurobi'   % Thanks to Wotao Yin's mex interface
        solver=8;
    case 'intlinprog'
        solver=9;
    otherwise
        error('unknown LP solver');
end
