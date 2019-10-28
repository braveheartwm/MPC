function expcon=reduce(expcon,tol)
% REDUCE Eliminate regions whose Chebychev radius is smaller than a given tolerance
%
% EXPCON1=REDUCE(EXPCON,TOL) eliminate regions whose Chebychev radius is smaller 
% than the given tolerance TOL, and enlarge the remaining regions so that no hole 
% remains.
% 
% (C) 2003 by A. Bemporad


if nargin<1,
    error('expcon:reduce:none','No EXPCON object supplied.');
end
if ~isa(expcon,'expcon'),
    error('expcon:reduce:obj','Invalid EXPCON object');
end

if nargin<2,
    warning('No reduction performed');
    return
end

if ~isnumeric(tol) | tol<0 | isinf(tol),
    error('expcon:reduce:out','Invalid reduction tolerance');
end

nr=expcon.nr;

exp1=struct(expcon); % Moves field 'rCheb' to main root of structure
exp1.rCheb=exp1.info.rCheb;
expcon=reduce(exp1,tol);
if nr>expcon.nr,
    expcon.info.colors=[];
end
expcon.info.rCheb=expcon.rCheb; % Moves field 'rCheb' back to 'info' structure
expcon=rmfield(expcon,'rCheb');

expcon=class(expcon,'expcon');