function Value = get(expcon,Property)
%GET  Access/query expcon property values.
%
%   VALUE = GET(expcon,'PropertyName') returns the value of the 
%   specified property of the expcon object expcon.  An equivalent
%   syntax is 
%       VALUE = expcon.PropertyName .
%   
%   STRUCT = GET(expcon) converts the expcon object expcon into 
%   a structure STRUCT with the property names as field names and
%   the property values as field values.
%
%   Without left-hand argument, GET(expcon) displays all properties 
%   of expcon and their values. 
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
        error('mpc:expconget:nargin',aux.message);
    end
end

if ni==2,
    % GET(expcon,'Property') or GET(expcon,{'Prop1','Prop2',...})
    CharProp = ischar(Property);
    if CharProp,
        Property = {Property};
    elseif ~iscellstr(Property)
        error('mpc:expconget:name','Property name must be a string or a cell vector of strings.')
    end
    
    % Get all public properties
    AllProps = pnames(expcon);
    
    % Loop over each queried property 
    Nq = prod(size(Property)); 
    Value = cell(1,Nq);
    for i=1:Nq,
        % Find match for k-th property name and get corresponding value
        % RE: a) Must include all properties to detect multiple hits
        %     b) Limit comparison to first 7 chars
        try 
            propstr=lower(Property{i});
            Value{i} = pvget(expcon,pnmatch(propstr,AllProps,7));
        catch
            rethrow(lasterror)
        end
    end
    
    % Strip cell header if PROPERTY was a string
    if CharProp,
        Value = Value{1};
    end
    
elseif nargout,
    % STRUCT = GET(expcon)
    Value = cell2struct(pvget(expcon),pnames(expcon),1);
    
else
    % GET(expcon)
    PropStr = pnames(expcon);
    [junk,ValStr] = pvget(expcon);
    disp(pvformat(PropStr,ValStr))
    
end
