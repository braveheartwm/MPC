function [Ny,Nu,Ncu,Ncy]=chkinterval(interval,movesdef);

%CHKINTERVAL Check interval structure
%
%(C) 2003 by A. Bemporad

if ~isa(interval,'struct'),
    error('INTERVAL must be a structure of number of input and output optimal control steps');
end

fields={'N','Nu','Ncu','Ncy'};

s=fieldnames(interval); % get field names
for i=1:length(s),
    Name=s{i};
    name=lower(Name);
    
    j=find(ismember(lower(fields),name)); % locate name within 'fields'
    if isempty(j), % field inexistent
        error(sprintf('The field ''%s'' in INTERVAL is invalid',Name));
    else
        aux=fields{j};
        eval(['w=interval.' Name ';']);
        if ~isa(w,'double'),
            error(['INTERVAL.' Name ' must be a nonnegative integer.']);
        else
            w=round(w);
            eval(['interval.' aux '=w;']);
        end
    end
end   

% Define missing fields
for i=1:length(fields),
    aux=fields{i};
    if ~isfield(interval,aux),
        eval(['interval.' aux '=[];']);
    end
end

Nu=interval.Nu;
if isempty(Nu),
    warning(sprintf('No input interval specified, assuming the number of free control moves is Nu=%d',movesdef));
    Nu=movesdef;
end
Ny=interval.N;
if isempty(Ny),
    Ny=Nu;
end
Ncy=interval.Ncy;
if isempty(Ncy),
    Ncy=Ny-1;
end
Ncu=interval.Ncu;
if isempty(Ncu),
    Ncu=Nu-1;
end

if Nu>Ny,
   Nu=Ny;
   warning(sprintf('Nu>Ny. Setting Nu=Ny=%d',Nu));
end
if Ncy>Ny-1,
   Ncy=Ny-1;
   warning(sprintf('Ncy>Ny-1. Setting Ncy=Ny-1=%d',Ncy));
end
if Ncy<0,
   Ncy=0;
   warning(sprintf('Ncy<0. Setting Ncy=%d',Ncy));
end
if Ncu>Ny-1,
   Ncu=Ny-1;
   warning(sprintf('Ncu>Ny-1. Setting Ncu=Ny-1=%d',Ncu));
end