function C2=preprocess(C,hybsys,range,options)
%PREPROCESS Reduces computational complexity of on-line MIP problem 
%
% C2=PREPROCESS(C,SYS,RANGE,OPTIONS) preprocess controller C by adding useful cuts
% that reduce the complexity of on-line optimization.
%
% C is a constrained optimal controller for hybrid systems based on on-line MIP
% optimization (an object of class @HYBCON).
%
% SYS is a hybrid model (an object of class @MLD or @PWA).
%
% RANGE optionally defines a range of states and inputs of the hybrid systems that
% will occur during the execution of the controller (it may be different from the limits 
% over variables imposed in the control law). RANGE is a structure with fields:
%    .xmin, xmax = range of states            [ xmin <= x <= xmax ]
%    .umin, umax = range of inputs            [ umin <= u <= umax ]
% By default, ranges are inherited from the range specified HYSDEL model.
%
% OPTIONS defines various options for preprocessing the mixed-integer program.
% options.verbose=1: show information
%                =0: silent
% options.lpsolver=   LP solver (type "help lptype" for available options) 
% options.milpsolver= MILP solver. Valid options are:
%      'dantz'   uses DANTZGMP.DLL 
%      'glpk'    uses GLPKMEX.DLL 
%      'nag'     uses MIQP3_NAF.M based on E04MBF.M for LP
%      'matlab'  uses MIQP3_NAF.M based on LP.M for LP
%      'cplex'   uses MILP_CPLEX.DLL
%
% See also HYBCON, EXPCON.

% (C) 2004 by Alberto Bemporad

if nargin<1,
    error('hybcon:preprocess:none','No HYBCON object supplied.');
end
if ~isa(hybcon,'hybcon'),
    error('hybcon:preprocess:obj','Invalid HYBCON object');
end
if nargin<2,
    error('hybcon:preprocess:nohybsys','No MLD or PWA object supplied.');
end
if ~isa(hybsys,'mld') & ~isa(hybsys,'pwa'),
    error('hybcon:preprocess:hybsys','Invalid hybrid model object');
end

C2=C;

% Convert MLD model to PWA form

% Performs reachability analysis

% Add "no-good" constraints on integer vars