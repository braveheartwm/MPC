function [refs,Tdef]=chkrefs(refs,islin,ishyb,nx,nu,ny,nz,refsdef,lintracking,Tstop,isexp)
%CHKREFS Check structure of references
%
%(C) 2003 by A. Bemporad

if isnan(lintracking),
    lintracking=0;
end
if islin & ~lintracking,
    refs=[];
    Tdef=1;
    return
end

if ~isa(refs,'struct'),
    error('refs must be a structure of references');
end

fields={'x', 'u','z','y'};

s=fieldnames(refs); % get field names
for i=1:length(s),
    Name=s{i};
    name=lower(Name);
    
    j=find(ismember(lower(fields),name)); % locate name within 'fields'
    if isempty(j), % field inexistent
        error(sprintf('The field ''%s'' in refs is invalid',Name));
    else
        aux=fields{j};
        eval(['ref=refs.' Name ';']);
        if ~isa(ref,'double'),
            error(['refs.' Name ' must be real valued.']);
        end
        if (islin & (strcmp(name,'x') | strcmp(name,'u') |...
                strcmp(name,'z'))) | ...
                (islin & ~lintracking & strcmp(name,'y')),
            warning(sprintf('Reference %s will be ignored',Name));
        end
    end
end   

% Define missing fields
for i=1:length(fields),
    aux=fields{i};
    if ~isfield(refs,aux),
        if (ishyb & isexp & (strcmp(aux,'x') | strcmp(aux,'u') | strcmp(aux,'y'))) | ...
                (ishyb & ~isexp & (strcmp(aux,'x') | strcmp(aux,'u') | strcmp(aux,'y') | strcmp(aux,'z'))) | ...
                (islin & lintracking & strcmp(aux,'y')),
            eval(['def=refsdef.' aux ';']);
            eval(['refs.' aux '=def;']);
        end
    end
end

if ishyb,
    [errmsg,refs.y]=chkrefs2('y',refs.y,ny,refsdef.y);
    error(errmsg);
    [errmsg,refs.x]=chkrefs2('x',refs.x,nx,refsdef.x);
    error(errmsg);
    [errmsg,refs.u]=chkrefs2('u',refs.u,nu,refsdef.u);
    error(errmsg);
    if ~isexp,
        [errmsg,refs.z]=chkrefs2('z',refs.z,nz,refsdef.z);
        error(errmsg);
        Tdef=max([size(refs.y,1),size(refs.x,1),size(refs.u,1),size(refs.z,1),Tstop]);
        aux=refs.z;len=size(aux,1);
        refs.z=[aux;ones(Tdef-len,1)*aux(len,:)]; 
    else
        Tdef=max([size(refs.y,1),size(refs.x,1),size(refs.u,1),Tstop]);
    end
    aux=refs.x;len=size(aux,1);
    refs.x=[aux;ones(Tdef-len,1)*aux(len,:)]; 
    aux=refs.u;len=size(aux,1);
    refs.u=[aux;ones(Tdef-len,1)*aux(len,:)]; 
    aux=refs.y;len=size(aux,1);
    refs.y=[aux;ones(Tdef-len,1)*aux(len,:)]; 
end
if islin,
    if lintracking,
        [errmsg,refs.y]=chkrefs2('y',refs.y,ny,refsdef.y);
        error(errmsg);
        Tdef=max([size(refs.y,1),Tstop]);
        aux=refs.y;len=size(aux,1);
        refs.y=[aux;ones(Tdef-len,1)*aux(len,:)]; 
    else 
        Tdef=Tstop;
        if isempty(Tdef),
            Tdef=10;
        end
    end
end


%-----------------------
function [errmsg,newref]=chkrefs2(a,aref,Na,def)
% Determine validity of upper and lower bound matrices

errmsg='';
newref=aref; % Otherwise if an error occurs aref is not defined

if isempty(aref),
    newref=def;
    return
end

len=size(aref,2);
if len ~= Na,
    errmsg=['refs.' a ' should have ' ...
            int2str(Na) ' columns, you provided ' int2str(len)];
    return
end

%end chkrefs2
