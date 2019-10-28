function [umin,umax,ymin,ymax,dumin,dumax,isconstr]=chklimits(limits,type,nu,ny,limsdef);
%CHKLIMITS Check limits structure
%
%(C) 2003 by A. Bemporad

if ~isa(limits,'struct'),
    error('LIMITS must be a structure of upper and lower bounds on system variables');
end
tracking=strcmp(type,'track');

fields={'umin','umax','dumin','dumax','ymin','ymax'};

s=fieldnames(limits); % get field names
for i=1:length(s),
    Name=s{i};
    name=lower(Name);
    
    j=find(ismember(lower(fields),name)); % locate name within 'fields'
    if isempty(j), % field inexistent
        error(sprintf('The field ''%s'' in LIMITS is invalid',Name));
    else
        aux=fields{j};
        eval(['lim=limits.' Name ';']);
        if ~isa(lim,'double'),
            error(['LIMITS.' Name ' must be real valued.']);
        end
        if (strcmp(name,'dumin') | strcmp(name,'dumax')) & ~tracking,
            warning(sprintf('Constraints on input increments will be ignored, controller type is ''%s''',type));
        end
    end
end   

% Define missing fields
for i=1:length(fields),
    aux=fields{i};
    isdu=strcmp(aux,'dumin') | strcmp(aux,'dumax');
    if ~isdu | (isdu & tracking),
        if ~isfield(limits,aux),
            eval(['limdef=limsdef.' aux ';']);
            eval(['limits.' aux '=limdef;']);
        end
    end
end

[errmsg,umin,umax]=chklims('u',limits.umin,limits.umax,nu);
error(errmsg);

[errmsg,ymin,ymax]=chklims('y',limits.ymin,limits.ymax,ny);
error(errmsg);

if tracking,
    dumin=limits.dumin;
    dumax=limits.dumax;
end

% Check if the problem has any bounded constraint on u,du,y or not.
if tracking,
    isconstr=any(isfinite([umin(:);umax(:);dumin(:);dumax(:);ymin(:);ymax(:)]));
else
    isconstr=any(isfinite([umin(:);umax(:);ymin(:);ymax(:)]));
end
    
% if isconstr,
%     bound=verylow; % Need to lowerbound free vars, because QP solver requires vars>=0
% else
%     bound=-Inf;
% end
verylow=-Inf;

if tracking,
    if isempty(dumin),
        dumin=verylow*ones(nu,1); % Default for dumin
    end
    [errmsg,dumin,dumax]=chklims('du',dumin,dumax,nu);
    error(errmsg);
    
%     ifound=find(dumin<verylow);
%     
%     if ~isempty(ifound) & ~isempty(find(isfinite(dumin(ifound)))),
%         warning(sprintf('One or more constraints on input increments are < %g.\n%s',verylow,...
%             'Modified to prevent numerical problems in QP.'));
%     end
%     dumin(ifound)=verylow;
    
else
    if isempty(umin),
        umin=verylow*ones(nu,1); % Default for umin
    end
%     ifound=find(umin<verylow);
%     
%     if ~isempty(ifound) & ~isempty(find(isfinite(umin(ifound)))),
%         warning(sprintf('One or more constraints on inputs are < %g.\n%s',verylow,...
%             'Modified to prevent numerical problems in QP.'));
%     end
%     umin(ifound)=verylow;
    dumin=-Inf*ones(nu,1);
    dumax=Inf*ones(nu,1);
end


%-----------------------
function [errmsg,newamin,newamax]=chklims(a,amin,amax,Na)
% Determine validity of upper and lower bound matrices

errmsg='';
newamin=amin(:); % Otherwise if an error occurs amin is not defined
newamax=amax(:); % Otherwise if an error occurs amin is not defined

len=size(newamin,1);
if len ~= Na,
    errmsg=['LIMITS.' a 'min should have ' ...
            int2str(Na) ' entries, you specified ' int2str(len)];
    return
end
len=size(newamax,1);
if len ~= Na,
    errmsg=['LIMITS.' a 'max should have ' ...
            int2str(Na) ' entries, you specified ' int2str(len)];
    return
end

if any(any(newamax<=newamin))
    errmsg=['A lower bound on variable ' a ' is not less than its corresponding upper bound'];
    return
end

%end chklims
