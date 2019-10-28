function Value = get(hybcon,Property)
%GET  Access/query hybcon property values.
%
%   VALUE = GET(hybcon,'PropertyName') returns the value of the 
%   specified property of the hybcon object hybcon.  An equivalent
%   syntax is 
%       VALUE = hybcon.PropertyName .
%   
%   STRUCT = GET(hybcon) converts the hybcon object hybcon into 
%   a structure STRUCT with the property names as field names and
%   the property values as field values.
%
%   Without left-hand argument, GET(hybcon) displays all properties 
%   of hybcon and their values. 
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
        error('mpc:hybconget:nargin',aux.message);
    end
end

if ni==2,
    % GET(hybcon,'Property') or GET(hybcon,{'Prop1','Prop2',...})
    CharProp = ischar(Property);
    if CharProp,
        Property = {Property};
    elseif ~iscellstr(Property)
        error('mpc:hybconget:name','Property name must be a string or a cell vector of strings.')
    end
    
    % Get all public properties
    AllProps = pnames(hybcon);
    
    % Loop over each queried property 
    Nq = prod(size(Property)); 
    Value = cell(1,Nq);
    for i=1:Nq,
        % Find match for k-th property name and get corresponding value
        % RE: a) Must include all properties to detect multiple hits
        %     b) Limit comparison to first 7 chars
        try 
            propstr=lower(Property{i});
            Value{i} = pvget(hybcon,pnmatch(propstr,AllProps,7));
        catch
            rethrow(lasterror)
        end
    end
    
    % Strip cell header if PROPERTY was a string
    if CharProp,
        Value = Value{1};
    end
    
elseif nargout,
    % STRUCT = GET(hybcon)
    Value = cell2struct(pvget(hybcon),pnames(hybcon),1);
    
else
    % GET(hybcon)
    PropStr = pnames(hybcon);
    [junk,ValStr] = pvget(hybcon);
    disp(pvformat(PropStr,ValStr))
    
end
