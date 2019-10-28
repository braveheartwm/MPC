function boo=isempty(S)
%ISEMPTY  True for empty MLD objects.
% 
%   ISEMPTY(S) returns 1 (true) if the MLD object S is empty
%    

%   (C) 2004 by A. Bemporad

if ~isa(S,'mld'),
    error('mld:isempty:obj','Invalid MLD object');
end

boo=isempty(S.MLDisvalid);
