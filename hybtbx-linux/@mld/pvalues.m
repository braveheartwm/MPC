function Values = pvalues(mld)
%PVALUES  Values of all public properties of an object
%
%   VALUES = PVALUES(MLD)  returns the list of values of all
%   public properties of the object MLD.  VALUES is a cell vector.
%
%   See also  GET.

%   (C) 2003 by A. Bemporad

Npublic = 23;  % Number of mld-specific public properties

% Values of public MLD properties

Values = struct2cell(mld);
Values = Values(1:Npublic);


% end mld/pvalues.m
