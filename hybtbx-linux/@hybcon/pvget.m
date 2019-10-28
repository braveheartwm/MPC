function [Value,ValStr] = pvget(hybcon,Property)
%PVGET  Get values of public HYBCON properties.
%
%   VALUES = PVGET(HYBCON) returns all public values in a cell
%   array VALUES.
%
%   VALUE = PVGET(HYBCON,PROPERTY) returns the value of the
%   single property with name PROPERTY.
%
%   See also GET.

%   (C) 2003 by A. Bemporad

if nargin==2,
   % Value of single property: VALUE = PVGET(HYBCON,PROPERTY)
   % Public HYBCON properties
   Value = builtin('subsref',hybcon,struct('type','.','subs',Property));
   
else
   % Return all public property values
   % RE: Private properties always come last in HYBCONPropValues
   HYBCONPropNames = pnames(hybcon);
   HYBCONPropValues = struct2cell(hybcon);
   Value = HYBCONPropValues(1:length(HYBCONPropNames));
   if nargout==2,
      ValStr = pvformat(Value);
   end
   
end