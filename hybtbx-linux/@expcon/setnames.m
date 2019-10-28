function setnames(C,unames,ynames)
% SETNAMES Set I/O names of linear model for explicit optimal control
%
% SETNAMES(EXPCON,UNames,Ynames) labels inputs and output signals of
% the linear model used for the optimal controller EXPCON according to
% the names stored in the cell array Unames,Ynames. 
%
% Possible existing names in EXPCON.model are overwritten.
%
% An alternative to using SETNAMES is to assign directly I/O names
% as InputName and OutputName properties of the LTI object used as 
% the linear model.
%
% Example: setnames(C1,{'Pressure','Air Flow'},{'Speed'}) labels input #1
% as 'Pressure', input #2 as 'Air Flow' and output #1 as 'Speed'.
%
% See also EXPCON.

% (C) 2003 by Alberto Bemporad

% See also LINCON/SETNAMES, the functions are copied

if nargin<1,
    error('expcon:setnames:none','No EXPCON object supplied.');
end
if ~isa(C,'expcon'),
    error('expcon:setnames:obj','Invalid EXPCON object');
end

sys=C.model;
ny=C.ny;
nu=C.nu;

if nargin<2,
    return;
end

istimevarying=isa(sys,'cell');

if ~istimevarying,
    IN=sys.InputName;
else
    IN=sys{1}.InputName;
end
if ~isa(unames,'cell'),
    error('expcon:setnames:unames','Unames must be a cell array of names');
end
for i=1:min(length(unames),nu),
    name=unames{i};
    if ~ischar(name),
        error('expcon:setnames:name',sprintf('Input name #%d must be a string',i));
    end
    IN{i}=name;
end
if length(unames)>nu,
    warning('Unames has more names than number of inputs. Extra names ignored');
end

if nargin>=3,
    if ~istimevarying,
        ON=sys.OutputName;
    else
        ON=sys{1}.OutputName;
    end
    if ~isa(ynames,'cell'),
        error('expcon:setnames:unames','Ynames must be a cell array of names');
    end
    for i=1:min(length(ynames),ny),
        name=ynames{i};
        if ~ischar(name),
            error('expcon:setnames:name',sprintf('Output name #%d must be a string',i));
        end
        ON{i}=name;
    end
    if length(ynames)>ny,
        warning('Ynames has more names than number of outputs. Extra names ignored');
    end
end

if ~istimevarying,
    set(sys,'InputName',IN,'OutputName',ON);
else
    for i=1:length(sys),
        sys{i}.InputName=IN;
        sys{i}.OutputName=ON;
    end
end
C.model=sys;

% Assign EXPCON in caller's workspace
assignin('caller',inputname(1),C);