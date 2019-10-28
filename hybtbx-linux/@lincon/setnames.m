function setnames(C,unames,ynames)
% SETNAMES Set I/O names of linear model for optimal control
%
% SETNAMES(LINCON,UNames,Ynames) labels inputs and output signals of
% the linear model used for the optimal controller LINCON according to
% the names stored in the cell array Unames,Ynames.
%
% Possible existing names in LINCON.model are overwritten.
%
% An alternative to using SETNAMES is to assign directly I/O names
% as InputName and OutputName properties of the LTI object used as
% the linear model.
%
% Example: setnames(C1,{'Pressure','Air Flow'},{'Speed'}) labels input #1
% as 'Pressure', input #2 as 'Air Flow' and output #1 as 'Speed'.
%
% See also LINCON.

% (C) 2003-2009 by Alberto Bemporad

% See also EXPCON/SETNAMES, the functions are copied

if nargin<1,
    error('lincon:setnames:none','No LINCON object supplied.');
end
if ~isa(C,'lincon'),
    error('lincon:setnames:obj','Invalid LINCON object');
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
    error('lincon:setnames:unames','Unames must be a cell array of names');
end
for i=1:min(length(unames),nu),
    name=unames{i};
    if ~ischar(name),
        error('lincon:setnames:name',sprintf('Input name #%d must be a string',i));
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
        error('lincon:setnames:unames','Ynames must be a cell array of names');
    end
    for i=1:min(length(ynames),ny),
        name=ynames{i};
        if ~ischar(name),
            error('lincon:setnames:name',sprintf('Output name #%d must be a string',i));
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

% Assign LINCON in caller's workspace
assignin('caller',inputname(1),C);