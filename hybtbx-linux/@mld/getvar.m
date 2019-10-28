function [index,kind,extra]=getvar(mld,name)
%GETVAR Get information about a HYSDEL variable of an MLD system
%
%   INDEX=GETVAR(MLD,NAME) get the position INDEX of variable NAME
%   within its corresponding vector (x, u, y, d, or z)
%
%   [INDEX,KIND]=GETVAR(MLD,NAME) also gets the type of vector (x, u, y, d, or z)
%   variable NAME belongs to. KIND='p' if NAME is a parameter
%
%   [INDEX,KIND,EXTRA]=GETVAR(MLD,NAME) also gets all information related
%   to variable NAME 

%   (C) 2003-2007 by A. Bemporad

if nargin<1,
    error('mld:getindex:none','No MLD object supplied.');
end
if nargin<2,
    error('mld:getindex:name','No variable name supplied.');
end
if ~isa(mld,'mld'),
    error('mld:getindex:obj','Invalid MLD object');
end

try
    str=syminfo(mld,name); % Where is variable <name> located in the corresponding vector ?
catch
    error('mld:getindex:unknown','Unknown HYSDEL variable');
end
extra=str{1};


kind=extra.kind;
try
    index=str{1}.index;
catch
    index=[];
end

if extra.type=='b',
    switch kind
        case 'u',
            index=index+mld.nur;
        case 'y',
            index=index+mld.nyr;
        case 'x',
            index=index+mld.nxr;
    end
end

if nargout==1,
    clear kind extra
end