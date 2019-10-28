function Out = set(hybcon,varargin)
%SET  Set properties of hybcon objects.
%
%   SET(hybcon,'PropertyName',VALUE) sets the property 'PropertyName'
%   of hybcon to the value VALUE.  An equivalent syntax 
%   is 
%       hybcon.PropertyName = VALUE .
%
%   SET(hybcon,'Property1',Value1,'Property2',Value2,...) sets multiple 
%   property values with a single statement.
%
%   SET(hybcon,'Property') displays legitimate values for the specified
%   property of hybcon.
%
%   SET(hybcon) displays all properties of hybcon and their admissible 
%   values.  
%
%   See also GET.

%   (C) 2003 by A. Bemporad

swarn=warning;
%warning on; % to avoid backtrace
warning backtrace off; % to avoid backtrace

ni = nargin;
no = nargout;
if ~isa(hybcon,'hybcon'),
   % Call built-in SET. Handles calls like set(gcf,'user',ss)
   builtin('set',hybcon,varargin{:});
   return
elseif no & ni>2,
   error('hybcon:set:out','Output argument allowed only in SET(hybcon) or SET(hybcon,Property)');
end

% Get properties and their admissible values when needed
if ni<=2,
   [AllProps,AsgnValues] = pnames(hybcon);
else
   AllProps = pnames(hybcon);
end

% Handle read-only cases
if ni==1,
   % SET(hybcon) or S = SET(hybcon)
   if no,
      Out = cell2struct(AsgnValues,AllProps,1);
   else
      disp(pvformat(AllProps,AsgnValues));
   end
   return

elseif ni==2,
   % SET(hybcon,'Property') or STR = SET(hybcon,'Property')
   
   Property = varargin{1};
   if ~ischar(Property),
      error('hybcon:set:name','Property names must be single-line strings.')
   end

   % Return admissible property value(s)
   imatch = strmatch(lower(Property),lower(AllProps));
   aux=PropMatchCheck(length(imatch),Property);
   if ~isempty(aux),
       error('hybcon:set:match',aux);
   end
   if no,
      Out = AsgnValues{imatch};
   else
      disp(AsgnValues{imatch})
   end
   return

end


% Now left with SET(hybcon,'Prop1',Value1, ...)

name = inputname(1);
if isempty(name),
   error('hybcon:set:first','First argument to SET must be a named variable.')
elseif rem(ni-1,2)~=0,
   error('hybcon:set:pair','Property/value pairs must come in even number.')
end

for i=1:2:ni-1,
   % Set each PV pair in turn
   PropStr = varargin{i};
   if ~isstr(PropStr),
      error('hybcon:set:string','Property names must be single-line strings.')
   end
   
   %propstr=lower(PropStr);
   %imatch = strmatch(propstr,lower(AllProps));
   propstr=PropStr;  
   imatch = strmatch(propstr,AllProps); % 'Lower' removed to avoid ambiguous props.

   aux=PropMatchCheck(length(imatch),PropStr);
   if ~isempty(aux),
      error('hybcon:set:match',aux);
   end
   Property = AllProps{imatch};
   Value = varargin{i+1};
   
   % Just sets what was required, will check later on when all 
   % properties have been set
   
   eval(['hybcon.' Property '=Value;']);
end   

warning(swarn);

% Finally, assign hybcon in caller's workspace
assignin('caller',name,hybcon);


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
