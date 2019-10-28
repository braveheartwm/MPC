function Values = pvalues(hybcon)
%PVALUES  Values of all public properties of an object
%
%   VALUES = PVALUES(HYBCON)  returns the list of values of all
%   public properties of the object HYBCON.  VALUES is a cell vector.
%
%   See also  GET.

%   (C) 2003 by A. Bemporad

Npublic = 23;  % Number of hybopt-specific public properties

% Values of public HYBOPT properties

Values = struct2cell(hybcon);
Values = Values(1:Npublic);


% end hybcon/pvalues.m
