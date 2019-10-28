function hybcon = subsasgn(hybcon,Struct,rhs)
%SUBSREF  hybcon property management in assignment operation
%
%   hybcon.Field = Value sets the 'Field' property of the hybcon object hybcon 
%   to the value Value. Is equivalent to SET(hybcon,'Field',Value)
%

%   (C) 2003 by A. Bemporad

if nargin==1,
    return
elseif ~isa(hybcon,'hybcon') & ~isempty(hybcon)
    hybcon = builtin('subsasgn',hybcon,Struct,rhs);
    return
end
StructL = length(Struct);

% Peel off first layer of subassignment
switch Struct(1).type
    case '.'
        % Assignment of the form hybcon.fieldname(...)=rhs
        FieldName = Struct(1).subs;
        try
            if StructL==1,
                FieldValue = rhs;
            else
                FieldValue = subsasgn(get(hybcon,FieldName),Struct(2:end),rhs);
            end
            set(hybcon,FieldName,FieldValue)
        catch
            rethrow(lasterror)
        end
    otherwise
         error('hybcon:subsasgn:support','This type of referencing is not supported for HYBCON objects.')
end