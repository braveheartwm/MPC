function Values = pvalues(pwa)
%PVALUES  Values of all public properties of an object
%
%   VALUES = PVALUES(PWA)  returns the list of values of all
%   public properties of the object PWA.  VALUES is a cell vector.
%
%   See also  GET.

%   (C) 2003 by A. Bemporad

Npublic = 18;  % Number of pwa-specific public properties

% Values of public PWA properties

Values = struct2cell(pwa);
Values = Values(1:Npublic);


% end pwa/pvalues.m
