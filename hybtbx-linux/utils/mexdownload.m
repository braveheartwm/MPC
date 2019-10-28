function mexdownload(path)
% MEXDOWNLOAD Download the mex files required on Win64 machines for the installed MATLAB version
%
% MEXDOWNLOAD        Download required mex files in default utils/ folder
% MEXDOWNLOAD(path)  Download required mex files to specified path
%
% (C) 2012 by D. Barcelli and A. Bemporad, May 11, 2012

if strcmp(computer,'PCWIN64') || strcmp(computer,'WIN64')
    matlabVersion=version('-release');
    matlabVersion=['R' matlabVersion];
else
    error('Automatic download only supported for Windows 64 machines.');
end

if nargin<1 || isempty(path),
    filename='mexdownload.m'; % This file
    path=which(filename);
    path=path(1:end-length(filename));
end

filenames={'glpkcc','glpkmex','mexclp','cddmex'};
extension='.mexw64';
baseURL='http://cse.lab.imtlucca.it/~bemporad/hybrid/toolbox/files/win64mex/';

% save current path
mypath=pwd;

% browse to correct path
cd(path);


for i=1:numel(filenames)
    filename=[filenames{i} extension];
    URL=[baseURL(:);matlabVersion(:);'/';filename(:)]';
    try
        urlwrite(URL,filename);
    catch me
        error(['Failed to dowload file.\n'
            'You may want to try to download from the following URL:\n' URL]);
    end
end

% go back to original path
cd(mypath);
end