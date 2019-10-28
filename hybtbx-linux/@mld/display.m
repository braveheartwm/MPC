function display(mld)
%DISPLAY Display an MLD object

%   (C) 2003 by A. Bemporad
S=inputname(1);
if isempty(mld),
    disp('Empty MLD object');
    return
end

disp(sprintf('\nMLD hybrid model generated from the HYSDEL file <%s.hys>\n',mld.hysmodel));
disp(sprintf('%3d states    (%d continuous, %d binary)',mld.nx,mld.nxr,mld.nxb));
disp(sprintf('%3d inputs    (%d continuous, %d binary)',mld.nu,mld.nur,mld.nub));
disp(sprintf('%3d outputs   (%d continuous, %d binary)',mld.ny,mld.nyr,mld.nyb));
disp(' ')
disp(sprintf('%3d continuous auxiliary variables',mld.nz));
disp(sprintf('%3d binary auxiliary variables',mld.nd));
disp(sprintf('%3d mixed-integer linear inequalities',mld.ne));
disp(' ')
disp(sprintf('sampling time: %g    MILP solver: ''%s''',mld.ts,mld.milpsolver));
% if ~isempty(mld.simname),
%     disp(sprintf('open-loop model simulator: %s.m',mld.simname));
% end
disp(' ')
disp(sprintf('Type %s.rowinfo for information about dynamics and constraints.',S));
disp(sprintf('Type %s.symtable for information about variables.',S));
disp(sprintf('Type "struct(%s)" for extra details.',inputname(1)));
