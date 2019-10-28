function display(expcon)
%DISPLAY Display an EXPCON object
%
%   (C) 2003 by A. Bemporad

if isempty(expcon),
    disp('Empty EXPCON object');
    return
end

S=inputname(1);
if expcon.info.ishyb,
    contype='hybrid';
end
if expcon.info.islin,
    contype='constrained linear';
end
if expcon.info.ismpc,
    contype='mpc';
end

disp(sprintf('\nExplicit controller (based on %s controller %s)',...
    contype,expcon.info.name));
disp(sprintf('%3d parameter(s)',expcon.npar));
disp(sprintf('%3d input(s)',expcon.nu));
disp(sprintf('%3d partition(s)',sum(expcon.nr)));
disp(sprintf('sampling time = %g',expcon.ts));
disp(' ')
sys='????';
type='tracking';
if expcon.info.islin | expcon.info.ismpc,
    sys='linear';
    if ~expcon.info.lintracking,
        type='regulation to the origin';
    end
end
if expcon.info.ishyb,
    sys='hybrid';
end
disp(sprintf('The controller is for %s systems (%s) [%d-norm]',sys,type,expcon.norm));
% For backwards compatibility:
if iscell(expcon.Observer),
    expcon.Observer=expcon.Observer{1};
end

if ~isstruct(expcon.Observer) & (ischar(expcon.Observer) | isnan(expcon.Observer)), 
    % Either 'no' or NaN, and not a structure
    disp('This is a state-feedback controller.');
else
    disp('This is an output-feedback controller.');
end    
disp(' ')
disp(sprintf('Type "struct(%s)" for more details.',inputname(1)));