function hysdel(filename,simname,options)
% hysdel(filename,simname,options)
% Compiles the HYSDEL list <filename.hys>,
% generates the M-file <filename.m>
%
% INPUT:
% filename: the hysdel source
% simname : if not empty, generates the HYSDEL simulator (see manual)
% options : a string of space separated command line switches to append to
%           HYSDEL call (see HYSDEL manual, it includes: -p -a -5
%           --no-symbol-table --no-row-info --no-params-checks
%           --matlab-symbolic -v[0-3])
%
% OUTPUT:
% filename.m and simname.m on disk
%
% (C) 2000-2002 F.D. Torrisi, Automatic Control Laboratory, ETH Zentrum, CH-8092 Zurich, Switzerland%
% Modified by A. Bemporad, 2004-2011

% Removes extension
if isunix
    %hysdel_cmd = './hysdel'; % if you move reneame hysdel customize here
    %hysdel_cmd = which('hysdel'); % Fixed by Mianyu Wang
    hysdel_cmd = which('hysdel.m');
    if strcmp(computer(),'MACI64')
        hysdel_cmd = regexprep(hysdel_cmd,'hysdel.m','hysdel_maci64');
    end
    if strcmp(computer(),'MACI')
        hysdel_cmd = regexprep(hysdel_cmd,'hysdel.m','hysdel_maci32');
    end
    if strcmp(computer(),'GLNX86')
        hysdel_cmd = regexprep(hysdel_cmd,'hysdel.m','hysdel_linux32');
    end
    if strcmp(computer(),'GLNXA64')
        hysdel_cmd = regexprep(hysdel_cmd,'hysdel.m','hysdel_linux64');
    end
    if strcmp(computer(),'SOL64')
        hysdel_cmd = regexprep(hysdel_cmd,'hysdel.m','hysdel_sun');
    end
    len = length(hysdel_cmd);
    if hysdel_cmd(end-1) == '.'
        hysdel_cmd = hysdel_cmd(1:end-2);
    end
else
    hysdel_cmd = which('hysdel.exe');
end

if (nargin < 3)
    options = [];
    if (nargin < 2)
        simname = [];
        if (nargin < 1)
            % print version and exit
            cmd_line = ' -V';
            eval(['!' hysdel_cmd cmd_line ]);
            return
        end
    end
end


j=findstr(filename,'.');
if ~isempty(j),
    if strcmpi(filename(j(end):end),'.hys')
        filename(j(end):end)=[];
    end
end

j=findstr(simname,'.');
if ~isempty(j),
    if strcmpi(simname(j(end):end),'.m')
        simname(j(end):end)=[];
    end
end


cmd_line = [' -i' filename '.hys -m' filename ];
if ~isempty(simname),
    cmd_line = [cmd_line ' -s' simname ' '];
end
if ~isempty(options),
    cmd_line = [cmd_line ' ' options];
end

% compile
eval(['!"' hysdel_cmd '"' cmd_line]);

% execute HYSDEL output to load the system S
% eval(filename); % this will not work if your system has symbolic parameters
% and therefore has been disabled
% write 'filename.mat'
% eval(['save ' filename]);



