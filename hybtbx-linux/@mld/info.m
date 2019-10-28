function out = info(MLD, vname, vtype, vkind, vindex)
% INFO Extract information from the symbolic table associated with an MLD model
%
% out = syminfo(S, vname, vtype, vkind, vindex)
% look up the symble table for entries matching the query 
% item.name == name AND item.type == type AND item.kind == kind
% empty field ('') matches all entries
% 
% INPUT:
% S     : the system name
% vname : var name as in the Hysdel source
% vtype : var type ('b','r')
% vkind : var kind ('x','u','d','z')
% vindex: var index
%
% OUTPUT
% out  : cell array of info records satisfying the query
% 
% REMARK
% the contents of the syminfo records are detailed in the HYSDEL manual in the 
% section describing the MLD-structure

% See MLD, HYSDEL.

% (C) 2003 by A. Bemporad

if nargin<1,
    error('mld:info:none','No MLD object supplied');
end
if ~isa(MLD,'mld'),
    error('mld:info:obj','Invalid MLD object');
end

if nargin<5|isempty(vindex),
    vindex='';
end
if nargin<4|isempty(vkind),
    vkind='';
end
if nargin<3|isempty(vtype),
    vtype='';
end
if nargin<2|isempty(vname),
    vname='';
end
    
try
   out=syminfo(MLD, vname, vtype, vkind, vindex);
catch
   out=[];
end
