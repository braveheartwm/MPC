function Out = set(pwa,varargin)
%SET  Set properties of pwa objects.
%
%   SET(pwa,'PropertyName',VALUE) sets the property 'PropertyName'
%   of pwa to the value VALUE.  An equivalent syntax 
%   is 
%       pwa.PropertyName = VALUE .
%
%   SET(pwa,'Property1',Value1,'Property2',Value2,...) sets multiple 
%   property values with a single statement.
%
%   SET(pwa,'Property') displays legitimate values for the specified
%   property of pwa.
%
%   SET(pwa) displays all properties of pwa and their admissible 
%   values.  
%
%   See also GET.

%   (C) 2003 by A. Bemporad

swarn=warning;
%warning on; % to avoid backtrace
warning backtrace off; % to avoid backtrace

ni = nargin;
no = nargout;
if ~isa(pwa,'pwa'),
   % Call built-in SET. Handles calls like set(gcf,'user',ss)
   builtin('set',pwa,varargin{:});
   return
elseif no & ni>2,
   error('pwa:set:out','Output argument allowed only in SET(pwa) or SET(pwa,Property)');
end

% Get properties and their admissible values when needed
if ni<=2,
   [AllProps,AsgnValues] = pnames(pwa);
else
   AllProps = pnames(pwa);
end

% Handle read-only cases
if ni==1,
   % SET(pwa) or S = SET(pwa)
   if no,
      Out = cell2struct(AsgnValues,AllProps,1);
   else
      disp(pvformat(AllProps,AsgnValues));
   end
   return

elseif ni==2,
   % SET(pwa,'Property') or STR = SET(pwa,'Property')
   
   Property = varargin{1};
   if ~ischar(Property),
      error('pwa:set:name','Property names must be single-line strings.')
   end

   % Return admissible property value(s)
   imatch = strmatch(lower(Property),lower(AllProps));
   aux=PropMatchCheck(length(imatch),Property);
   if ~isempty(aux),
       error('pwa:set:match',aux);
   end
   if no,
      Out = AsgnValues{imatch};
   else
      disp(AsgnValues{imatch})
   end
   return

end


% Now left with SET(pwa,'Prop1',Value1, ...)

name = inputname(1);
if isempty(name),
   error('pwa:set:first','First argument to SET must be a named variable.')
elseif rem(ni-1,2)~=0,
   error('pwa:set:pair','Property/value pairs must come in even number.')
end

for i=1:2:ni-1,
   % Set each PV pair in turn
   PropStr = varargin{i};
   if ~isstr(PropStr),
      error('pwa:set:string','Property names must be single-line strings.')
   end
   
   propstr=lower(PropStr);
      
   imatch = strmatch(propstr,lower(AllProps),'exact');
   aux=PropMatchCheck(length(imatch),PropStr);
   if ~isempty(aux),
      error('pwa:set:match',aux);
   end
   Property = AllProps{imatch};
   Value = varargin{i+1};
   
   % Just sets what was required, will check later on when all 
   % properties have been set
   
   eval(['pwa.' Property '=Value;']);
end   

warning(swarn);

% Finally, assign pwa in caller's workspace
assignin('caller',name,pwa);


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
