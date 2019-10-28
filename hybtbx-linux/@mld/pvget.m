function [Value,ValStr] = pvget(mld,Property)
%PVGET  Get values of public MLD properties.
%
%   VALUES = PVGET(MLD) returns all public values in a cell
%   array VALUES.
%
%   VALUE = PVGET(MLD,PROPERTY) returns the value of the
%   single property with name PROPERTY.
%
%   See also GET.

%   (C) 2003 by A. Bemporad

if nargin==2,
   % Value of single property: VALUE = PVGET(MLD,PROPERTY)
   % Public MLD properties
   Value = builtin('subsref',mld,struct('type','.','subs',Property));
   
else
   % Return all public property values
   % RE: Private properties always come last in MLDPropValues
   MLDPropNames = pnames(mld);
   MLDPropValues = struct2cell(mld);
   Value = MLDPropValues(1:length(MLDPropNames));
   if nargout==2,
      ValStr = pvformat(Value);
   end
   
end