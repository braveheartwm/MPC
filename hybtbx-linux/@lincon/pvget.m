function [Value,ValStr] = pvget(lincon,Property)
%PVGET  Get values of public LINCON properties.
%
%   VALUES = PVGET(LINCON) returns all public values in a cell
%   array VALUES.
%
%   VALUE = PVGET(LINCON,PROPERTY) returns the value of the
%   single property with name PROPERTY.
%
%   See also GET.

%   (C) 2003 by A. Bemporad

if nargin==2,
   % Value of single property: VALUE = PVGET(LINCON,PROPERTY)
   % Public LINCON properties
   Value = builtin('subsref',lincon,struct('type','.','subs',Property));
   
else
   % Return all public property values
   % RE: Private properties always come last in LINCONPropValues
   LINCONPropNames = pnames(lincon);
   LINCONPropValues = struct2cell(lincon);
   Value = LINCONPropValues(1:length(LINCONPropNames));
   if nargout==2,
      ValStr = pvformat(Value);
   end
   
end