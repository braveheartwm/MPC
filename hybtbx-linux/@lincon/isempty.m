function boo=isempty(L)
%ISEMPTY  True for empty LINCON objects.
% 
%   ISEMPTY(L) returns 1 (true) if the LINCON object L is empty
%    

%   (C) 2004 by A. Bemporad

boo=isempty(L.type);