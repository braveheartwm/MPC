function Out = set(expcon,varargin)
%SET  Set properties of expcon objects.
%
%   SET(expcon,'PropertyName',VALUE) sets the property 'PropertyName'
%   of expcon to the value VALUE.  An equivalent syntax 
%   is 
%       expcon.PropertyName = VALUE .
%
%   SET(expcon,'Property1',Value1,'Property2',Value2,...) sets multiple 
%   property values with a single statement.
%
%   SET(expcon,'Property') displays legitimate values for the specified
%   property of expcon.
%
%   SET(expcon) displays all properties of expcon and their admissible 
%   values.  
%
%   See also GET.

%   (C) 2003 by A. Bemporad

swarn=warning;
%warning on; % to avoid backtrace
warning backtrace off; % to avoid backtrace

ni = nargin;
no = nargout;
if ~isa(expcon,'expcon'),
   % Call built-in SET. Handles calls like set(gcf,'user',ss)
   builtin('set',expcon,varargin{:});
   return
elseif no & ni>2,
   error('expcon:set:out','Output argument allowed only in SET(expcon) or SET(expcon,Property)');
end

% Get properties and their admissible values when needed
if ni<=2,
   [AllProps,AsgnValues] = pnames(expcon);
else
   AllProps = pnames(expcon);
end

% Handle read-only cases
if ni==1,
   % SET(expcon) or S = SET(expcon)
   if no,
      Out = cell2struct(AsgnValues,AllProps,1);
   else
      disp(pvformat(AllProps,AsgnValues));
   end
   return

elseif ni==2,
   % SET(expcon,'Property') or STR = SET(expcon,'Property')
   
   Property = varargin{1};
   if ~ischar(Property),
      error('expcon:set:name','Property names must be single-line strings.')
   end

   % Return admissible property value(s)
   imatch = strmatch(lower(Property),lower(AllProps));
   aux=PropMatchCheck(length(imatch),Property);
   if ~isempty(aux),
       error('expcon:set:match',aux);
   end
   if no,
      Out = AsgnValues{imatch};
   else
      disp(AsgnValues{imatch})
   end
   return

end


% Now left with SET(expcon,'Prop1',Value1, ...)

name = inputname(1);
if isempty(name),
   error('expcon:set:first','First argument to SET must be a named variable.')
elseif rem(ni-1,2)~=0,
   error('expcon:set:pair','Property/value pairs must come in even number.')
end

for i=1:2:ni-1,
   % Set each PV pair in turn
   PropStr = varargin{i};
   if ~isstr(PropStr),
      error('expcon:set:string','Property names must be single-line strings.')
   end
   
   propstr=lower(PropStr);
      
   imatch = strmatch(propstr,lower(AllProps));
   aux=PropMatchCheck(length(imatch),PropStr);
   if ~isempty(aux),
      error('expcon:set:match',aux);
   end
   Property = AllProps{imatch};
   Value = varargin{i+1};
   
   % Just sets what was required, will check later on when all 
   % properties have been set
   
   eval(['expcon.' Property '=Value;']);
end   

warning(swarn);

% Finally, assign expcon in caller's workspace
assignin('caller',name,expcon);


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
