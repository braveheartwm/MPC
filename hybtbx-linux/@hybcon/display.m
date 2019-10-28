function display(hybcon)
%DISPLAY Display an HYBCON object
%
%   (C) 2003 by A. Bemporad

if isempty(hybcon),
    disp('Empty HYBCON object');
    return
end

S=inputname(1);
disp(sprintf('\nHybrid controller based on MLD model %s <%s.hys> [%d-norm]\n',...
    hybcon.model,hybcon.hysmodel,hybcon.norm));
disp(sprintf('%3d state measurement(s)',hybcon.nx));
disp(sprintf('%3d output reference(s)',length(hybcon.refsignals.y)));
disp(sprintf('%3d input reference(s)',length(hybcon.refsignals.u)));
disp(sprintf('%3d state reference(s)',length(hybcon.refsignals.x)));
disp(sprintf('%3d reference(s) on auxiliary continuous z-variables',length(hybcon.refsignals.z)));
disp(' ')
[nq,nvar]=size(hybcon.A);
nivar=length(hybcon.ivar);
disp(sprintf('%3d optimization variable(s) (%d continuous, %d binary)',nvar,nvar-nivar,nivar));
disp(sprintf('%3d mixed-integer linear inequalities',nq));
if isinf(hybcon.norm),
    solvertype='MILP';
else
    solvertype='MIQP';
end
disp(sprintf('sampling time = %g, %s solver = ''%s''',hybcon.ts,solvertype,hybcon.mipsolver));
disp(' ')
disp(sprintf('Type "struct(%s)" for more details.',inputname(1)));
