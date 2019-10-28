function Value = get(pwa,Property)
%GET  Access/query pwa property values.
%
%   VALUE = GET(pwa,'PropertyName') returns the value of the 
%   specified property of the pwa object pwa.  An equivalent
%   syntax is 
%       VALUE = pwa.PropertyName .
%   
%   STRUCT = GET(pwa) converts the pwa object pwa into 
%   a structure STRUCT with the property names as field names and
%   the property values as field values.
%
%   Without left-hand argument, GET(pwa) displays all properties 
%   of pwa and their values. 
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
        error('mpc:pwaget:nargin',aux.message);
    end
end


if ni==2,
    % GET(pwa,'Property') or GET(pwa,{'Prop1','Prop2',...})
    CharProp = ischar(Property);
    if CharProp,
        Property = {Property};
    elseif ~iscellstr(Property)
        error('mpc:pwaget:name','Property name must be a string or a cell vector of strings.')
    end
    
    % Get all public properties
    AllProps = pnames(pwa);
    
    % Loop over each queried property 
    Nq = prod(size(Property)); 
    Value = cell(1,Nq);
    for i=1:Nq,
        % Find match for k-th property name and get corresponding value
        % RE: a) Must include all properties to detect multiple hits
        %     b) Limit comparison to first 7 chars
        try 
            propstr=lower(Property{i});
            Value{i} = pvget(pwa,pnmatch(propstr,AllProps,7));
        catch
            rethrow(lasterror)
        end
    end
    
    % Strip cell header if PROPERTY was a string
    if CharProp,
        Value = Value{1};
    end
    
elseif nargout,
    % STRUCT = GET(pwa)
    Value = cell2struct(pvget(pwa),pnames(pwa),1);
    
else
    % GET(pwa)
    PropStr = pnames(pwa);
    [junk,ValStr] = pvget(pwa);
    disp(pvformat(PropStr,ValStr))
    
end
