function Values = pvalues(expcon)
%PVALUES  Values of all public properties of an object
%
%   VALUES = PVALUES(EXPCON)  returns the list of values of all
%   public properties of the object EXPCON.  VALUES is a cell vector.
%
%   See also  GET.

%   (C) 2003 by A. Bemporad

Npublic = 19;  % Number of expcon-specific public properties

% Values of public EXPCON properties

Values = struct2cell(expcon);
Values = Values(1:Npublic);


% end expcon/pvalues.m
