function Out = set(mld,varargin)
%SET  Set properties of mld objects.
%
%   SET(mld,'PropertyName',VALUE) sets the property 'PropertyName'
%   of mld to the value VALUE.  An equivalent syntax 
%   is 
%       mld.PropertyName = VALUE .
%
%   SET(mld,'Property1',Value1,'Property2',Value2,...) sets multiple 
%   property values with a single statement.
%
%   SET(mld,'Property') displays legitimate values for the specified
%   property of mld.
%
%   SET(mld) displays all properties of mld and their admissible 
%   values.  
%
%   See also GET.

%   (C) 2003 by A. Bemporad

swarn=warning;
%warning on; % to avoid backtrace
warning backtrace off; % to avoid backtrace

ni = nargin;
no = nargout;
if ~isa(mld,'mld'),
   % Call built-in SET. Handles calls like set(gcf,'user',ss)
   builtin('set',mld,varargin{:});
   return
elseif no & ni>2,
   error('mld:set:out','Output argument allowed only in SET(mld) or SET(mld,Property)');
end

% Get properties and their admissible values when needed
if ni<=2,
   [AllProps,AsgnValues] = pnames(mld);
else
   AllProps = pnames(mld);
end

% Handle read-only cases
if ni==1,
   % SET(mld) or S = SET(mld)
   if no,
      Out = cell2struct(AsgnValues,AllProps,1);
   else
      disp(pvformat(AllProps,AsgnValues));
   end
   return

elseif ni==2,
   % SET(mld,'Property') or STR = SET(mld,'Property')
   
   Property = varargin{1};
   if ~ischar(Property),
      error('mld:set:name','Property names must be single-line strings.')
   end

   % Return admissible property value(s)
   imatch = strmatch(lower(Property),lower(AllProps),'exact');
   aux=PropMatchCheck(length(imatch),Property);
   if ~isempty(aux),
       error('mld:set:match',aux);
   end
   if no,
      Out = AsgnValues{imatch};
   else
      disp(AsgnValues{imatch})
   end
   return

end


% Now left with SET(mld,'Prop1',Value1, ...)

name = inputname(1);
if isempty(name),
   error('mld:set:first','First argument to SET must be a named variable.')
elseif rem(ni-1,2)~=0,
   error('mld:set:pair','Property/value pairs must come in even number.')
end

for i=1:2:ni-1,
   % Set each PV pair in turn
   PropStr = varargin{i};
   if ~isstr(PropStr),
      error('mld:set:string','Property names must be single-line strings.')
   end
   
   propstr=lower(PropStr);
      
   imatch = strmatch(propstr,lower(AllProps));
   aux=PropMatchCheck(length(imatch),PropStr);
   if ~isempty(aux),
      error('mld:set:match',aux);
   end
   Property = AllProps{imatch};
   Value = varargin{i+1};
   
   % Just sets what was required, will check later on when all 
   % properties have been set
   
   eval(['mld.' Property '=Value;']);
end   

warning(swarn);

% Finally, assign mld in caller's workspace
assignin('caller',name,mld);


% subfunction PropMatchCheck
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function errmsg = PropMatchCheck(nhits,Property)
% Issues a standardized error message when the property name 
% PROPERTY is not uniquely matched.

if nhits==1,
   errmsg = '';
elseif nhits==0,
   errmsg = ['Invalid property name "' Property '".']; 
else
   errmsg = ['Ambiguous property name "' Property '". Supply more characters.'];
end
