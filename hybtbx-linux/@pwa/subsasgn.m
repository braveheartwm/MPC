function pwa = subsasgn(pwa,Struct,rhs)
%SUBSREF  pwa property management in assignment operation
%
%   PWA.Field = Value sets the 'Field' property of the pwa object PWA 
%   to the value Value. Is equivalent to SET(PWA,'Field',Value)
%

%   (C) 2003 by A. Bemporad

if nargin==1,
    return
elseif ~isa(pwa,'pwa') & ~isempty(pwa)
    pwa = builtin('subsasgn',pwa,Struct,rhs);
    return
end
StructL = length(Struct);

% Peel off first layer of subassignment
switch Struct(1).type
    case '.'
        % Assignment of the form pwa.fieldname(...)=rhs
        FieldName = Struct(1).subs;
        try
            if StructL==1,
                FieldValue = rhs;
            else
                FieldValue = subsasgn(get(pwa,FieldName),Struct(2:end),rhs);
            end
            set(pwa,FieldName,FieldValue)
        catch
            rethrow(lasterror)
        end
    otherwise
         error('pwa:subsasgn:support','This type of referencing is not supported for PWA objects.')
end