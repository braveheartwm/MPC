function result = subsref(pwa,Struct)
%SUBSREF  Subscripted reference for pwa objects.
%
%   The following reference operation can be applied to any 
%   pwa object: 
%      pwa.Fieldname  equivalent to GET(pwa,'Fieldname')
%   These expressions can be followed by any valid subscripted
%   reference of the result, as in  SYS(1,[2 3]).inputname  or
%   SYS.num{1,1}.
%
%
%   See also GET.

%   (C) 2003 by A. Bemporad

% Effect on pwa properties: all inherited

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
         result = get(pwa,Struct(1).subs);   
      else
         %Struct(2).subs=names(Struct(1).subs,Struct(2).subs);
         result = subsref(get(pwa,Struct(1).subs),Struct(2:end));
      end
   catch
      error(lasterr)
   end
otherwise
   error('pwa:subsref:ref',['Unknown reference type: ' Struct(1).type])
end
