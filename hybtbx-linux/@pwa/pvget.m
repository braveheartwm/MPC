function [Value,ValStr] = pvget(pwa,Property)
%PVGET  Get values of public PWA properties.
%
%   VALUES = PVGET(PWA) returns all public values in a cell
%   array VALUES.
%
%   VALUE = PVGET(PWA,PROPERTY) returns the value of the
%   single property with name PROPERTY.
%
%   See also GET.

%   (C) 2003 by A. Bemporad

if nargin==2,
   % Value of single property: VALUE = PVGET(PWA,PROPERTY)
   % Public PWA properties
   Value = builtin('subsref',pwa,struct('type','.','subs',Property));
   
else
   % Return all public property values
   % RE: Private properties always come last in PWAPropValues
   PWAPropNames = pnames(pwa);
   PWAPropValues = struct2cell(pwa);
   Value = PWAPropValues(1:length(PWAPropNames));
   if nargout==2,
      ValStr = pvformat(Value);
   end
   
end