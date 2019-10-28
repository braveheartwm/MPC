function handles=polyplot3d(A,b,c,shaded,az,el);
% POLYPLOT3D  Plot three-dimensional polytopes.
%
%           POLYPLOT3D(A,B) plots the polytope {x: Ax<=B}. It it
%           assumed that Ax<=B does not have redundant inequalities
%           (see POLYREDUCE).
%
%           POLYPLOT3D(A,B,C) use color C.
%
%           POLYPLOT3D(A,B,C,shaded) draws the polytope 
%           with FaceAlpha=shaded, or without fill color if shaded=0.
%
%           handles=POLYPLOT3D(A,B,C,shaded) also returns handles to the
%           PATCH objects defining the facets
%
%           handles=POLYPLOT3D(A,B,C,shaded,az,el) also specifies azimuth
%           and elevation for the 3D view (type "help view" for more info)
%
% See also POLYPLOT for two-dimensional plots.
%
% (C) 2006 by A. Bemporad

if nargin<4 | isempty(shaded),
    shaded=0.3;
end
if nargin<3 | isempty(c),
    c=rand(3,1);
end

clear H
H.A=A;
H.B=b;

% Find vertices
[V,Ad]=cddmex('adj_extreme',H); % A{i} contains adjacent vertices of vertex #i
V=V.V; % Just gets vertices, assuming rays are not present

% Find coplanar vertices
nv=size(V,1); % Number of vertices
q=size(A,1); % Number of hyperplanes
faces=logical(zeros(q,nv));
for i=1:q,
    faces(i,find(abs(A(i,:)*V'-b(i))<=1e-6))=1;
end

hhold=ishold;

handles=zeros(q,1);
for i=1:q,
    vert=find(faces(i,:));
    % sort by adjacency
    j=2;
    while j<length(vert),
        if ~any(Ad{vert(j-1)}==vert(j)), % vert(j) is not adjacent to vert(j-1)
            aux=vert(j);     
            vert(j:end-1)=vert(j+1:end); % shift vertices 
            vert(end)=aux;     % move vertex #j to the end
        else
            j=j+1; % vertex is adjacent, go on with next vertex
        end
    end
    X=V(vert,:);
    h=fill3(X(:,1),X(:,2),X(:,3),c(:)');
    hold on
    set(h,'FaceAlpha',shaded,'EdgeColor',c*.5,'EdgeAlpha',shaded);
    handles(i)=h;
end
if ~hhold,
    hold off % Plot was not held
end

if nargout<1,
    clear handles
end