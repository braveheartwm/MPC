function [v,V]=polyvolume(A,b)
% POLYVOLUME Compute the volume of a polyhedron in R^n.
%
%           v=POLYVOLUME(A,B) returns the volume of polytope {x: A*x <= b}
%
%           [v,V]=POLYVOLUME(A,B) also returns the vertices of the polyhedron
%
% The volume is computed in a rather inefficient way: (1) enumerate the
% vertices of the polyhedron, (2) compute Delaunay triangulation, (3)
% compute and sum the volumes of each simplex.
%
% (C) 2011 by A. Bemporad

clear H
H.A=A;
H.B=b;

n=size(A,2); % Space dimension

% Find vertices
V=cddmex('extreme',H);
if ~isempty(V.R),
    % Extreme rays are present, volume is infinite
    v=Inf;
    return
end
V=V.V; % Just gets vertices, assuming rays are not present

% Delaunay triangulation
if n==2,
    T=delaunay(V(:,1),V(:,2));
elseif n==3,
    T=delaunay3(V(:,1),V(:,2),V(:,3));
else
    warning('polyvolume:delaynayn','Using Delaunay triangulation in a high-dimensional space');
    T=delaunayn(V,{'Qt','Qbb','Qc','Qz'});
end

% Sum volumes of each simplex
v=0;
for i=1:size(T,1),
    %v=v+abs(det([ones(n+1,1) V(T(i,:),:)])); % This one statement is
    % equivalent to the following commands, but seems a bit slower
    Z=zeros(n,n);
    v0=V(T(i,1),:)';
    for j=2:n+1,
       Z(:,j-1)=V(T(i,j),:)'-v0;
    end
    v=v+abs(det(Z));
end
v=v/factorial(n);
