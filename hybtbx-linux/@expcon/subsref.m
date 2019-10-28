function result = subsref(expcon,Struct)
%SUBSREF  Subscripted reference for expcon objects.
%
%   The following reference operation can be applied to any 
%   expcon object: 
%      expcon.Fieldname  equivalent to GET(expcon,'Fieldname')
%   These expressions can be followed by any valid subscripted
%   reference of the result, as in  SYS(1,[2 3]).inputname  or
%   SYS.num{1,1}.
%
%
%   See also GET.

%   (C) 2003 by A. Bemporad

% Effect on expcon properties: all inherited

ni = nargin;
if ni==1,
   result = sys;
   return
end
StructL = length(Struct);

% Peel off first layer of subreferencing
switch Struct(1).type
case '.'
   
   % The first subreference is of the form sys.fieldname
   % The output is a piece of one of the system properties
   try
      if StructL==1,
         result = get(expcon,Struct(1).subs);   
      else
         %Struct(2).subs=names(Struct(1).subs,Struct(2).subs);
         result = subsref(get(expcon,Struct(1).subs),Struct(2:end));
      end
   catch
      error(lasterr)
   end
otherwise
   error('expcon:subsref:ref',['Unknown reference type: ' Struct(1).type])
end
