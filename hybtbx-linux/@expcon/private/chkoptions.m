function options=chkoptions(options,contype,optionsdef,refyindex,refxindex,refuindex,nxr,nxb,nur,nub,nyr,nyb)
%CHKOPTIONS Check options of parameters structure

%(C) 2003-2004 by A. Bemporad

if ~isa(options,'struct'),
    error('OPTIONS must be a structure of option parameters');
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
        
fields={'lpsolver','qpsolver','fixref','valueref','fixmd','valuemd',...
    'noslack','flattol','waitbar','verbose',...
    'mplpverbose','uniteeps','join','reltol','sequence'};

s=fieldnames(options); % get field names
for i=1:length(s),
    Name=s{i};
    name=lower(Name);
    
    j=find(ismember(lower(fields),name)); % locate name within 'fields'
    if isempty(j), % field inexistent
        error(sprintf('The field ''%s'' in OPTIONS is invalid',Name));
    end   
end

if ishyb && isfield(options,'sequence'),
    warning('Option ''sequence'' ignored for hybrid MPC');
end

% Define missing fields
for i=1:length(fields),
    aux=fields{i};
    eval(['def=optionsdef.' aux ';']);
    if isfield(options,aux),
        eval(['aux2=options.' aux ';']);
    else
        aux2=[];
    end
    if isempty(aux2),
        eval(['options.' aux '=def;']);
    end
end

if ishyb,
    % Check fields 'fixref','valueref'
    if ~isa(options.fixref,'struct'),
        error('options.fixref must be a structure with fields ''y'', ''x'', and ''u''');
    else
         if ~isfield(options.fixref,'x'),
             options.fixref.x=[];
         end
         if ~isfield(options.fixref,'u'),
             options.fixref.u=[];
         end
         if ~isfield(options.fixref,'y'),
             options.fixref.y=[];
         end
     end
     if ~isa(options.valueref,'struct'),
         error('options.valueref must be a structure with fields ''y'', ''x'', and ''u''');
     else
         if ~isfield(options.valueref,'x'),
             options.valueref.x=[];
         end
         if ~isfield(options.valueref,'u'),
             options.valueref.u=[];
         end
         if ~isfield(options.valueref,'y'),
             options.valueref.y=[];
         end
     end
    if any(~ismember(options.fixref.y,refyindex)),
        error('You fixed a reference signal for an output for which a reference signal was not defined');
    end
    if any(~ismember(options.fixref.x,refxindex)),
        error('You fixed a reference signal for a state for which a reference signal was not defined');
    end
    if length(options.fixref.y(:))~=length(options.valueref.y(:)),
        error('options.fixref.y and options.valueref.y do not match');
    end
    if length(options.fixref.x(:))~=length(options.valueref.x(:)),
        error('options.fixref.x and options.valueref.x do not match');
    end
    if any(~ismember(options.fixref.u,refuindex)),
        error('You fixed a reference signal for an input for which a reference signal was not defined');
    end
    if length(options.fixref.u(:))~=length(options.valueref.u(:)),
        error('options.fixref.u and options.valueref.u do not match');
    end
    refyb=refxindex(find(refyindex>nyr)); % Binary outputs who have a reference
    if ~all(ismember(refyb,options.fixref.y)),
        error('References for binary outputs must be fixed.');
    end
    refxb=refxindex(find(refxindex>nxr)); % Binary states who have a reference
    if ~all(ismember(refxb,options.fixref.x)),
        error('References for binary states must be fixed.');
    end
    refub=refuindex(find(refuindex>nur)); % Binary inputs who have a reference
    if ~all(ismember(refub,options.fixref.u)),
        error('References for binary inputs must be fixed.');
    end
end