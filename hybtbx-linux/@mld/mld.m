function S = mld(hysfile,ts,solver,simname,options)
%MLD Constructor for @mld class -- Hybrid MLD model
%
%   S=MLD(filename) generates an MLD model from the HYSDEL list 
%   <filename.hys> and generates the M-file <filename.m>
%
%   S=MLD(filename,ts) specifies the sampling time of the MLD dynamics
%
%   S=MLD(filename,ts,solver) specifies the MILP solver used for updating
%   the MLD dynamics. Type "help milptype" for valid options.
%
%   S=MLD(filename,ts,solver,simname) also generates the HYSDEL simulator (see manual)
%   <simname.m> corresponding to the hysdel model in <filename.hys>
%
%   S=MLD(filename,ts,solver,simname,options) specifies a string of space separated 
%   command line switches to append to the HYSDEL compiler call.
%   (see HYSDEL manual, it includes: -p -a -5 
%           --no-symbol-table --no-row-info --no-params-checks )
%
% See also MLD/UPDATE, MLD/SIM, HYBCON, HYBCON/EVAL, PWA.

%   (C) 2003-2006 by A. Bemporad

if nargin<1,
    % Empty MLD object
    thedir=pwd;
    emptyhys='mld___empty';
    privdir=which([emptyhys '.hys']);
    privdir=privdir(1:end-length(emptyhys)-5);
    try
        cd(privdir)
        eval(emptyhys);
        
        % Clean up fields
        fi=fieldnames(S);
        for i=1:length(fi),
            S=setfield(S,fi{i},[]);
        end
        S.ts=[];
        S.simname=[];
        S.milpsolver=[];
        S.params=[];
        S.hysmodel=[];
        S=class(S,'mld');
        cd(thedir)
        return    
    catch
        cd(thedir)
        error('mld:class','Unable to initialize @MLD class');
    end
end

if ~ischar(hysfile),
    error('mld:file','Argument of MLD must be a valid HYSDEL file');
end
if isempty(hysfile),
    error('mld:empty','No file name supplied');
end

if nargin<2 || isempty(ts),
    warning('No sampling time provided, assuming sampling time = 1 s');
    ts=1;
else
    if ~isnumeric(ts) || ts<=0 || numel(ts)~=1,
        error('Sampling time must be a positive scalar');
    end
end
if nargin<3 || isempty(solver),
    solver='glpk';
else
    if ~ischar(solver)|| (~strcmp(solver,'glpk') && ~strcmp(solver,'cplex') && ...
            ~strcmp(solver,'matlab') && ~strcmp(solver,'linprog') && ~strcmp(solver,'nag') ...
            && ~strcmp(solver,'xpress')),
        error('mld:simname','Invalid MILP solver, type "help milpsol" for valid options');
    end
end
if nargin<4 || isempty(simname),
    simname=sprintf('temp_%s_sim',hysfile);
else
    if ~ischar(simname),
        error('mld:simname','Invalid file name for simulator');
    end
end

if nargin<5 || isempty(options),
    options=[];
else
    if ~ischar(options),
        error('mld:options','Invalid options string for HYSDEL compiler');
    end
end


% Does there exist a variable called with the same name as the HYS file
% (and corresponding hysdel-generated M file) ?
try
    Msave=evalin('caller',hysfile); % Save a possible existing variable 
    evalin('caller',['clear ' hysfile]);
    isMsave=1;
catch ME
    isMsave=0;
end

currdir=pwd;
cdcurrdir=['cd(''' currdir ''')'];

% Hysdel file may be on path, but not in current directory
hysfile_path=[hysfile '.hys'];
hysfile_path=which(hysfile_path);

if ispc,
    copycmd='copy';
    rmdircmd='rmdir /S /Q';
    delcmd='del';
    movecmd='move';
    hysfile_path=['"' hysfile_path '"'];
else % Thanks to Mianyu Wang for fixing UNIX commands
    copycmd='cp';
    rmdircmd='rm -rf';
    delcmd='rm';
    movecmd='mv';
end

try
    if ~isempty(strfind(hysfile_path,' ')),
        fprintf('\nPath to HYSDEL file contains spaces, MLD constructor may fail.\n\n');
    end
    evalc('!mkdir temp');
    evalc(sprintf('!%s %s temp',copycmd,hysfile_path));  
    cd temp
    if isempty(simname) && isempty(options),
        msg=evalc('hysdel(hysfile)');
    elseif isempty(simname),
        msg=evalc('hysdel(hysfile,simname)');
    else 
        msg=evalc('hysdel(hysfile,simname,options)');
    end
    findwarn=findstr(msg,'Warning');
    if ~isempty(findwarn),
        warning(msg(findwarn+9:end));
    end
    evalc(sprintf('!%s %s.hys',delcmd,hysfile));  
catch ME
    evalc(cdcurrdir);
    evalc(sprintf('!%s temp',rmdircmd));
    rethrow(ME);
end

finderr=findstr(msg,'Error');
if ~isempty(finderr),
    evalc(cdcurrdir);
    evalc(sprintf('!%s temp',rmdircmd));
    error('File %s.hys: %s',hysfile,msg(finderr:end));
end

% this may not work if your system has symbolic parameters
try
    Ssave=evalin('caller','S'); % Save a possible existing variable S
    evalin('caller','clear S');
    isSsave=1;
catch ME
    isSsave=0;
end
try
    paramssave=evalin('caller','params'); % Save a possible existing variable S
    evalin('caller','clear params');
    isPsave=1;
catch ME
    isPsave=0;
end

evalin('caller','params=[];');
try
    % Look for symbolic pars
    s=textread([simname '.m'],'%s');
    % Looks for '~isfield(params,' string and stop at 'x=x(:);'
    i=1;
    stop=0;
    clear params
    while ~stop,
        if strcmp(s{i},'x=x(:);'),
            stop=1;
        else
            i=i+1;
            if strcmp(s{i},'~isfield(params,'),
                i=i+5;
                par=s{i};
                try
                    evalin('caller',sprintf('params.%s=%s;',par,par));
                catch ME
                    warning('Cannot evaluate parameter %s',par);    
                end
            end
        end
    end
catch ME
    evalc(cdcurrdir);
    evalc(sprintf('!%s temp',rmdircmd));
    disp('Problems with the HYSDEL compiler. Please check that the hysdel compiler in @mld/private is executable')
    disp('and that you have write permissions in the directory you''re currently working');
    rethrow(ME);
end

try
    evalin('caller',hysfile); % Assign S in the caller workspace, where possible symbolic vars are defined
    
    if isMsave,
        % Restore original variable
        assignin('caller',hysfile,Msave);
    end
    
    S=evalin('caller','S'); % Get S
    params=evalin('caller','params'); % Save params
    if isSsave,
        assignin('caller','S',Ssave);
    else
        evalin('caller','clear S');
    end
    if isPsave,
        assignin('caller','params',paramssave);
    else
        evalin('caller','clear params');
    end
    S.ts=ts;
    S.simname=simname;
    S.milpsolver=solver;
    S.params=params;
    S.hysmodel=hysfile;
    if ~isfield(S,'ne'),
        S.ne=size(S.E1,1); % This is to avoid a bug in HYSDEL when option '--no-row-info' is used
    end
    if ~isfield(S,'rowinfo'),
        S.rowinfo=''; % When option '--no-row-info' is used this field is not added by HYSDEL
    end
    S=class(S,'mld');
catch ME
    evalc(cdcurrdir);
    evalc(sprintf('!%s temp',rmdircmd));
    rethrow(ME);
end

if ispc && ~isempty(strfind(currdir,' ')), % Fix problem with spaces in path
    currdir = ['"' currdir '"'];
end
evalc(['!' movecmd ' ' simname '.m ' currdir]); 
evalc(cdcurrdir);
evalc(sprintf('!%s temp',rmdircmd));
