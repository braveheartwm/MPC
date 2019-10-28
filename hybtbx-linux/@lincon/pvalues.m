function Values = pvalues(lincon)
%PVALUES  Values of all public properties of an object
%
%   VALUES = PVALUES(HYBOPT)  returns the list of values of all
%   public properties of the object LINCON.  VALUES is a cell vector.
%
%   See also  GET.

%   (C) 2003 by A. Bemporad

Npublic = 23;  % Number of lincon-specific public properties

% Values of public LINCON properties

Values = struct2cell(lincon);
Values = Values(1:Npublic);


% end lincon/pvalues.m
