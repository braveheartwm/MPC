function range=chkrange(range,contype,nx,nu,ny,rangedef,lintracking,nrx,nru,nry,nv) %,nrz)
%CHKRANGE Check range of parameters structure

%(C) 2003 by A. Bemporad

if ~isa(range,'struct'),
    error('RANGE must be a structure of ranges of parameters');
end

islin=0;
ishyb=0;
ismpc=0;
switch contype
    case 1
        islin=1;
    case 2
        ishyb=1;
    case 3
        ismpc=1;
end

fields={'xmin', 'xmax','umin','umax','ymin', 'ymax','refymin','refymax',...
        'refxmin', 'refxmax', 'refumin', 'refumax','vmin','vmax'}; %,'refzmin', 'refzmax'};

s=fieldnames(range); % get field names
for i=1:length(s),
    Name=s{i};
    name=lower(Name);
    
    j=find(ismember(lower(fields),name)); % locate name within 'fields'
    if isempty(j), % field inexistent
        error(sprintf('The field ''%s'' in RANGE is invalid',Name));
    else
        aux=fields{j};
        eval(['lim=range.' Name ';']);
        if ~isa(lim,'double'),
            error(['RANGE.' Name ' must be real valued.']);
        end
        if (strcmp(name,'refxmin') | strcmp(name,'refxmax') | ...
                strcmp(name,'refumin') | strcmp(name,'refumax') | ...
                strcmp(name,'refzmin') | strcmp(name,'refzmax')) & (islin|ismpc),
            warning(sprintf('Range %s will be ignored, controller is for linear systems',Name));
        end
        if (strcmp(name,'ymin') | strcmp(name,'ymax')) & (islin|ismpc),
            warning(sprintf('Range %s will be ignored, controller is for linear systems',Name));
        end
        if (strcmp(name,'umin') | strcmp(name,'umax') | ...
                strcmp(name,'refymin') | strcmp(name,'refymax')) & ~lintracking & islin,
            warning(sprintf('Range %s will be ignored, controller is a regulator of linear systems to the origin',Name));
        end
    end
end   

% Define missing fields
for i=1:length(fields),
    aux=fields{i};
    if ~isfield(range,aux),
        if (strcmp(aux,'xmin') | strcmp(aux,'xmax')) |...
                (islin & lintracking & (strcmp(aux,'umin') | strcmp(aux,'umax'))) | ...
                (ishyb & (strcmp(aux,'refxmin') | strcmp(aux,'refxmax') | strcmp(aux,'refumin') ...
                | strcmp(aux,'refumax') | strcmp(aux,'refzmin') | strcmp(aux,'refzmax'))) | ...
                ((((islin | ismpc) & lintracking) | ishyb) & (strcmp(aux,'refymin') | strcmp(aux,'refymax'))) | ...
                ((strcmp(aux,'vmin') | strcmp(aux,'vmax')) & ismpc),
            eval(['def=rangedef.' aux ';']);
            eval(['range.' aux '=def;']);
        end
    end
end

[errmsg,range.xmin,range.xmax]=chkrangelims('x',range.xmin,range.xmax,nx);
error(errmsg);

if ishyb,
    [errmsg,range.refymin,range.refymax]=chkrangelims('refy',range.refymin,range.refymax,nry);
    error(errmsg);
    [errmsg,range.refxmin,range.refxmax]=chkrangelims('refx',range.refxmin,range.refxmax,nrx);
    error(errmsg);
    [errmsg,range.refumin,range.refumax]=chkrangelims('refu',range.refumin,range.refumax,nru);
    error(errmsg);
    %[errmsg,range.refzmin,range.refzmax]=chkrangelims('refz',range.refzmin,range.refzmax,nrz);
    %error(errmsg);
end
if ((islin|ismpc) & lintracking),
    [errmsg,range.refymin,range.refymax]=chkrangelims('refy',range.refymin,range.refymax,ny);
    error(errmsg);
end
if ((islin|ismpc) & lintracking),
    [errmsg,range.umin,range.umax]=chkrangelims('u',range.umin,range.umax,nu);
    error(errmsg);
end
if ismpc,
    [errmsg,range.vmin,range.vmax]=chkrangelims('v',range.vmin,range.vmax,nv);
    error(errmsg);
end


%-----------------------
function [errmsg,newamin,newamax]=chkrangelims(a,amin,amax,Na)
% Determine validity of upper and lower bound matrices

errmsg='';
newamin=amin(:); % Otherwise if an error occurs amin is not defined
newamax=amax(:); % Otherwise if an error occurs amin is not defined

len=length(amin);
if len==1,
    % Repeat bound on all components
    newamin=newamin*ones(Na,1);
    len=Na;
end
if len ~= Na,
    errmsg=['RANGE.' a 'min should have ' ...
            int2str(Na) ' entries, you specified ' int2str(len)];
    return
end
len=length(amax);

if len==1,
    % Repeat bound on all components
    newamax=newamax*ones(Na,1);
    len=Na;
end
if len ~= Na,
    errmsg=['RANGE.' a 'max should have ' ...
            int2str(Na) ' entries, you specified ' int2str(len)];
    return
end

if any(any(newamax<=newamin))
    errmsg=['A lower bound on variable ' a ' is not less than its corresponding upper bound'];
    return
end

%end chkrangelims
