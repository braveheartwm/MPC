function boo=isempty(H)
%ISEMPTY  True for empty HYBCON objects.
% 
%   ISEMPTY(H) returns 1 (true) if the HYBCON object H is empty
%    

%   (C) 2004 by A. Bemporad

boo=isempty(H.norm);