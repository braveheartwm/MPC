function [Value,ValStr] = pvget(expcon,Property)
%PVGET  Get values of public EXPCON properties.
%
%   VALUES = PVGET(EXPCON) returns all public values in a cell
%   array VALUES.
%
%   VALUE = PVGET(EXPCON,PROPERTY) returns the value of the
%   single property with name PROPERTY.
%
%   See also GET.

%   (C) 2003 by A. Bemporad

if nargin==2,
   % Value of single property: VALUE = PVGET(EXPCON,PROPERTY)
   % Public EXPCON properties
   Value = builtin('subsref',expcon,struct('type','.','subs',Property));
   
else
   % Return all public property values
   % RE: Private properties always come last in EXPCONPropValues
   EXPCONPropNames = pnames(expcon);
   EXPCONPropValues = struct2cell(expcon);
   Value = EXPCONPropValues(1:length(EXPCONPropNames));
   if nargout==2,
      ValStr = pvformat(Value);
   end
   
end