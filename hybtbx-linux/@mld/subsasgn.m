function mld = subsasgn(mld,Struct,rhs)
%SUBSREF  mld property management in assignment operation
%
%   mld.Field = Value sets the 'Field' property of the mld object mld 
%   to the value Value. Is equivalent to SET(mld,'Field',Value)
%

%   (C) 2003 by A. Bemporad

if nargin==1,
    return
elseif ~isa(mld,'mld') & ~isempty(mld)
    mld = builtin('subsasgn',mld,Struct,rhs);
    return
end
StructL = length(Struct);

% Peel off first layer of subassignment
switch Struct(1).type
    case '.'
        % Assignment of the form mld.fieldname(...)=rhs
        FieldName = Struct(1).subs;
        try
            if StructL==1,
                FieldValue = rhs;
            else
                FieldValue = subsasgn(get(mld,FieldName),Struct(2:end),rhs);
            end
            set(mld,FieldName,FieldValue)
        catch
            rethrow(lasterror)
        end
    otherwise
         error('mld:subsasgn:support','This type of referencing is not supported for MLD objects.')
end