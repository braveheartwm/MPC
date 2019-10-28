function Value = get(lincon,Property)
%GET  Access/query lincon property values.
%
%   VALUE = GET(lincon,'PropertyName') returns the value of the 
%   specified property of the lincon object lincon.  An equivalent
%   syntax is 
%       VALUE = lincon.PropertyName .
%   
%   STRUCT = GET(lincon) converts the lincon object lincon into 
%   a structure STRUCT with the property names as field names and
%   the property values as field values.
%
%   Without left-hand argument, GET(lincon) displays all properties 
%   of lincon and their values. 
%
%   See also SET.

%   (C) 2003 by A. Bemporad

% Generic GET method.
% Uses the object-specific methods PNAMES and PVALUES
% to get the list of all public properties and their
% values (PNAMES and PVALUES must be defined for each 
% particular child object)

ni = nargin;
try
    narginchk(1,2);
catch
    aux=nargchk(1,2,ni);
    if ~isempty(aux),
        error('mpc:linconget:nargin',aux.message);
    end
end

if ni==2,
    % GET(lincon,'Property') or GET(lincon,{'Prop1','Prop2',...})
    CharProp = ischar(Property);
    if CharProp,
        Property = {Property};
    elseif ~iscellstr(Property)
        error('mpc:linconget:name','Property name must be a string or a cell vector of strings.')
    end
    
    % Get all public properties
    AllProps = pnames(lincon);
    
    % Loop over each queried property 
    Nq = prod(size(Property)); 
    Value = cell(1,Nq);
    for i=1:Nq,
        % Find match for k-th property name and get corresponding value
        % RE: a) Must include all properties to detect multiple hits
        %     b) Limit comparison to first 7 chars
        try 
            propstr=lower(Property{i});
            Value{i} = pvget(lincon,pnmatch(propstr,AllProps,7));
        catch
            rethrow(lasterror)
        end
    end
    
    % Strip cell header if PROPERTY was a string
    if CharProp,
        Value = Value{1};
    end
    
elseif nargout,
    % STRUCT = GET(lincon)
    Value = cell2struct(pvget(lincon),pnames(lincon),1);
    
else
    % GET(lincon)
    PropStr = pnames(lincon);
    [junk,ValStr] = pvget(lincon);
    disp(pvformat(PropStr,ValStr))
    
end
