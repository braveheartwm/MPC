function expcon = subsasgn(expcon,Struct,rhs)
%SUBSREF  expcon property management in assignment operation
%
%   expcon.Field = Value sets the 'Field' property of the expcon object expcon 
%   to the value Value. Is equivalent to SET(expcon,'Field',Value)
%

%   (C) 2003 by A. Bemporad

if nargin==1,
    return
elseif ~isa(expcon,'expcon') & ~isempty(expcon)
    expcon = builtin('subsasgn',expcon,Struct,rhs);
    return
end
StructL = length(Struct);

% Peel off first layer of subassignment
switch Struct(1).type
    case '.'
        % Assignment of the form expcon.fieldname(...)=rhs
        FieldName = Struct(1).subs;
        try
            if StructL==1,
                FieldValue = rhs;
            else
                FieldValue = subsasgn(get(expcon,FieldName),Struct(2:end),rhs);
            end
            set(expcon,FieldName,FieldValue)
        catch
            rethrow(lasterror)
        end
    otherwise
         error('expcon:subsasgn:support','This type of referencing is not supported for EXPCON objects.')
end