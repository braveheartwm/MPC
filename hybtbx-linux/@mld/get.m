function Value = get(mld,Property)
%GET  Access/query mld property values.
%
%   VALUE = GET(mld,'PropertyName') returns the value of the 
%   specified property of the mld object mld.  An equivalent
%   syntax is 
%       VALUE = mld.PropertyName .
%   
%   STRUCT = GET(mld) converts the mld object mld into 
%   a structure STRUCT with the property names as field names and
%   the property values as field values.
%
%   Without left-hand argument, GET(mld) displays all properties 
%   of mld and their values. 
%
%   See also SET.

%   (C) 2003 by A. Bemporad

% Generic GET method.
% Uses the object-specific methods PNAMES and PVALUES
% to get the list of all public properties and their
% values (PNAMES and PVALUES must be defined for each 
% particular child object)

ni = nargin;
ni = nargin;
try
    narginchk(1,2);
catch
    aux=nargchk(1,2,ni);
    if ~isempty(aux),
        error('mpc:mldget:nargin',aux.message);
    end
end

if ni==2,
    % GET(mld,'Property') or GET(mld,{'Prop1','Prop2',...})
    CharProp = ischar(Property);
    if CharProp,
        Property = {Property};
    elseif ~iscellstr(Property)
        error('mpc:mldget:name','Property name must be a string or a cell vector of strings.')
    end
    
    % Get all public properties
    AllProps = pnames(mld);
    
    % Loop over each queried property 
    Nq = prod(size(Property)); 
    Value = cell(1,Nq);
    for i=1:Nq,
        % Find match for k-th property name and get corresponding value
        % RE: a) Must include all properties to detect multiple hits
        %     b) Limit comparison to first 7 chars
        try 
            propstr=lower(Property{i});
            Value{i} = pvget(mld,pnmatch(propstr,AllProps,7));
        catch
            rethrow(lasterror)
        end
    end
    
    % Strip cell header if PROPERTY was a string
    if CharProp,
        Value = Value{1};
    end
    
elseif nargout,
    % STRUCT = GET(mld)
    Value = cell2struct(pvget(mld),pnames(mld),1);
    
else
    % GET(mld)
    PropStr = pnames(mld);
    [junk,ValStr] = pvget(mld);
    disp(pvformat(PropStr,ValStr))
    
end
