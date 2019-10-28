function boo=isempty(E)
%ISEMPTY  True for empty EXPCON objects.
% 
%   ISEMPTY(E) returns 1 (true) if the EXPCON object E is empty
%    

%   (C) 2004 by A. Bemporad

boo=isempty(E.norm);