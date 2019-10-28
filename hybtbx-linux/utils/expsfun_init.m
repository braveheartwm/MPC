function nu=expsfun_init
% EXPSFUN_INIT Extract data from EXPCON Object, generate EXPCON.H file,
% and prepare expsfun.dll for linear/hybrid constrained controllers
% (state feedback) or linear constrained controllers (output feedback)

% (C) 2003-2009 by A. Bemporad

swarn=warning;
warning backtrace off; % to avoid backtrace

% Get parameters from block

gc=gcb;  % Use this when InitFcn or StartFcn is part of the block

C = strtrim(get_param(gc,'C'));
% The object name is obtained from the mask as a string. It must be evaluated.
if isempty(C),
    error('No controller specified');
end
try
    C=evalin('base',C);
catch
    rethrow(lasterror);
end
if ~isa(C,'expcon'),
    error('Controller must be a valid EXPCON object.');
end

nu=C.nu;
ny=C.ny;
nx=C.nx;
ts=C.ts;

islin=(C.info.islin || C.info.ismpc);
ishyb=C.info.ishyb;
ismpc=C.info.ismpc;

% For backwards compatibility:
if iscell(C.Observer),
    C.Observer=C.Observer{1};
end

if islin && C.info.lintracking && ~isstruct(C.Observer) && ~C.info.ismpc,
    warning('No observer designed -- Assuming default kalman filter (type "help kalmanhelp")');
    kalman(C);
end
flagobs=(~ischar(C.Observer)) & islin;

if flagobs, %Linear system w/ output feedback
    xhat0=strtrim(get_param(gc,'xhat0'));
    u1=strtrim(get_param(gc,'u1'));
    try
        xhat0=evalin('base',xhat0);
        u1=evalin('base',u1);
    catch
        rethrow(lasterror);
    end
    if isempty(xhat0),
        xhat0=zeros(nx,1);
    else
        if ~(length(xhat0(:))==nx),
            error(sprintf('Initial condition of state observer is invalid, must have %d entries',nx));
        end
    end
    if isempty(u1),
        u1=zeros(nu,1);
    else
        if ~length(u1(:))==nu,
            error(sprintf('Previous input is invalid, must have %d entries',nu));
        end
    end
end

% Determine if reference port is connected
no_ref=0;
ports=get_param(gc,'PortConnectivity');
if ports(2).SrcBlock<0,
    % Reference signal is not connected, must replace the scalar zero added 
    % by Simulink to xr with a vector of 0s
    no_ref=1;
end
if ~no_ref & islin & ~flagobs,
    warning('You specified a regulator to the origin, the reference signal will be ignored');
end
if ishyb,
    no_refx=0;
    if ports(3).SrcBlock<0,
        % State reference signal is not connected, must replace the scalar zero added 
        % by Simulink to xr with a vector of 0s
        no_refx=1;
    end
    no_refu=0;
    if ports(4).SrcBlock<0,
        % Input reference signal is not connected, must replace the scalar zero added 
        % by Simulink to xr with a vector of 0s
        no_refu=1;
    end
end

compile=strtrim(get_param(gc,'compile'));

if strcmp(compile,'on'),
    
    fprintf('Compiling S-function "expsfun.c" .... ');
    
    clear expsfun
    
    % Write H file
    zerotol=1e-10;
    type='double';

    thisdir=pwd;

    % Compile mex file
    filetolocate='mpqp.p';
    utildir=which(filetolocate);utildir=utildir(1:end-length(filetolocate));
    csfun=sprintf('%sexpsfun.c',utildir);
    eval(sprintf('cd ''%s''',utildir));
    
    if islin,
        if flagobs,
            hwrite(C,zerotol,type,u1,xhat0,'sfun',no_ref);
        else
            hwrite(C,zerotol,type,[],[],'sfun',no_ref);
        end
    else
        hwrite(C,zerotol,type,[],[],'sfun',no_ref,no_refu,no_refx);
    end
    
    % Mex files
    clear expsfun
    %eval(sprintf('mex -v "%s"',csfun)); 
    eval(sprintf('mex "%s"',csfun));
    eval(sprintf('cd ''%s''',thisdir));
    
    fprintf('Done!\n\n(uncheck "Generate MEX file" in the Simulink mask to avoid compiling the MEX at each execution)\n\n');

end

if flagobs,
    if ismpc,
        size(C.Observer,2);
    else
        nym=C.Observer.nym;
    end
else
    nym=C.nx;
end

Sstruct.no_ref=no_ref; % NOTE: RTW doesn't like non-numerical values !!
if ishyb,
    SStruct.no_refu=no_refu;
    SStruct.no_refx=no_refx;
end    

set_param(gc,'Userdata',Sstruct);

warning(swarn);


%---------------------------

function r = strtrim(s)
%STRTRIM Remove insignificant whitespace.
%   S = STRTRIM(S) removes insignificant whitespace from string S.
%
%   Whitespace characters are the following: V = char([9 10 11 12 13 32]), which
%   return true from ISSPACE(V). Per definition, insignificant leading
%   whitespace leads the first non-whitespace character, and insignificant
%   trailing whitespace follows the last non-whitespace character in a string.
%
%   A = STRTRIM(A) removes insignificant whitespace from the char array. 
%
%   C = STRTRIM(C), when C is a cell array of strings, removes insignificant
%   whitespace from each element of C. 
%
%   INPUT PARAMETERS:
%       S: any one of a char row vector, char array, or a cell array of strings.
%
%   RETURN PARAMETERS:
%       S: any one of a char vector, char array or a cell array of strings.
%
%   EXAMPLES:
%       S = STRTRIM(M) removes whitespace from the front and rear of S.
%       
%   See also CELL/STRTRIM, ISSPACE, CELLSTR.

try
    % initialise variables
    InvalidClass = 0;
    InvalidShape = 0;
    IsCharVector = size(s,1) == 1;
    front = 1;
    rear = 1;
    
    if IsCharVector
        % strtrim char vector
        % find indices of non-whitespace
        numChars = numel(s); % code optimised for performance. Equivalent to LENGTH(s).
        
        % find starting and ending indices of non-whitespace characters
        rear = numChars;
        front = 1;
        while (rear > 0 & isspace(s(rear)))
           rear = rear - 1;
        end
        while (front < numChars+1 & isspace(s(front)))
           front = front + 1;
        end
        
        if rear >= front % Check if string was all whitespace.
            r = s(front:rear); % extract significant substring.           
        else % return empty string
            r = '';
            return;
        end

    end
    if ~IsCharVector
        % strtrim char array
        % find indices of non-whitespace
        [rows,cols] = find(~isspace(s));
        if isempty(cols),
            r = '';
            return; % no non-whitespace were found in input.
        else
            front = min(cols); 
            rear = max(cols);
        end
        % Remove insignificant whitespace
        r = s(:,front:rear);    
    end
    
catch
    if ~isempty(nargchk(1,1,nargin)) % too few input arguments
        error(nargchk(1,1,nargin));

    else % rethrow undefined error
        error(lasterr);
    end
    
end

