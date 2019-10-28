function display(pwa)
%DISPLAY Display a PWA object

%   (C) 2003 by A. Bemporad

if isempty(pwa),
    disp('Empty PWA object');
    return
end

P=inputname(1);
disp(sprintf('\nPWA hybrid model defined over %d polyhedral regions and with',pwa.nr));
disp(sprintf('%3d state(s)    (%d continuous, %d binary)',pwa.nx,pwa.nxr,pwa.nxb));
disp(sprintf('%3d input(s)    (%d continuous, %d binary)',pwa.nu,pwa.nur,pwa.nub));
disp(sprintf('%3d output(s)  (%d continuous, %d binary)',pwa.ny,pwa.nyr,pwa.nyb));
disp(sprintf('\n%s was generated from the MLD system ''%s'' (HYSDEL model <%s.hys>, sampling time = %g). ',...
    P,pwa.mld,pwa.hysmodel,pwa.ts));
disp(sprintf('Type "struct(%s)" for full information.\n',P));