function lincon = subsasgn(lincon,Struct,rhs)
%SUBSREF  lincon property management in assignment operation
%
%   lincon.Field = Value sets the 'Field' property of the lincon object lincon 
%   to the value Value. Is equivalent to SET(lincon,'Field',Value)
%

%   (C) 2003 by A. Bemporad

if nargin==1,
    return
elseif ~isa(lincon,'lincon') & ~isempty(lincon)
    lincon = builtin('subsasgn',lincon,Struct,rhs);
    return
end
StructL = length(Struct);

% Peel off first layer of subassignment
switch Struct(1).type
    case '.'
        % Assignment of the form lincon.fieldname(...)=rhs
        FieldName = Struct(1).subs;
        try
            if StructL==1,
                FieldValue = rhs;
            else
                FieldValue = subsasgn(get(lincon,FieldName),Struct(2:end),rhs);
            end
            set(lincon,FieldName,FieldValue)
        catch
            rethrow(lasterror)
        end
    otherwise
         error('lincon:subsasgn:support','This type of referencing is not supported for HYBCON objects.')
end