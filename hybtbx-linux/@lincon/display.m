function display(lincon)
%DISPLAY Display a LINCON object
%
%   (C) 2003 by A. Bemporad

if isempty(lincon),
    disp('Empty LINCON object');
    return
end

S=inputname(1);
if lincon.isconstr,
    disp(sprintf('\n%s is a constrained controller based on QP solver ''%s''\n',...
        S,lincon.QPsolver));
else
    disp(sprintf('\n%s is a linear controller\n',S));
end
disp(sprintf('%3d output variable(s)',lincon.ny));
disp(sprintf('%3d input variable(s)',lincon.nu));
disp(sprintf('%3d state(s)',lincon.nx));
if strcmp(lincon.type,'track'),
    disp(sprintf('%3d reference(s) on output variables',lincon.ny));
end
disp(sprintf('%3d free continuous optimization variable(s)',lincon.nvar));
if lincon.isconstr,
    disp(sprintf('%3d linear inequalities',lincon.nq));
end

% For backwards compatibility:
if iscell(lincon.Observer),
    lincon.Observer=lincon.Observer{1};
end

if ischar(lincon.Observer),
    disp('This is a state-feedback controller.');
else
    disp('This is an output-feedback controller.');
end    
disp(' ')
disp(sprintf('Type "struct(%s)" for more details.',inputname(1)));