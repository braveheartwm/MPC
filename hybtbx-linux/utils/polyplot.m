function [V,handle]=polyplot(A,B,c,shaded,xmin,xmax,solver)
% POLYPLOT  Plot two-dimensional polytopes.
%
%           POLYPLOT(A,B) plots the polytope {x: Ax<=B}. It it
%           assumed that Ax<=B does not have redundant constraints
%           (see POLYREDUCE).
%
%           POLYPLOT(V) plots the polytope obtained by the convex
%           hull of points in the cell array V.
%
%           V=POLYPLOT(A,B) only returns the vertices in cell
%           array V (ordered)
%
%           [V,handle]=POLYPLOT(A,B) or handle=POLYPLOT(V)
%           also returns the handle to the PATCH object
%
%           POLYPLOT(A,B,c), POLYPLOT(V,c) draws the polytope with
%           fill color c=[r g b].
%
%           POLYPLOT(A,B,c,shaded), POLYPLOT(V,c,shaded) draws the polytope 
%           with FaceAlpha=shaded, or without fill color if shaded=0.
%
%           POLYPLOT(A,B,c,shaded,xmin,xmax,solver) intersects the polyhedron 
%           with the box xmin<=x<=xmax (useful for plotting unbounded polyhedra).
%           The LP solver "solver" is used for removing redundant
%           inequalities.
%
% See also POLYPLOT3D for three-dimensional plots.
%
% (C) 2003-2004 by A. Bemporad

if nargin<1,
    error('Empty arguments');
end

shaded_default=0.6;

if ~isa(A,'cell') & exist('xmin') & exist('xmax'),
    if ~all(xmin<=xmax),
        error('XMIN must be smaller or equal to XMAX');
    end
    nx=size(A,2);
    if prod(size(xmin))==1,
        xmin=xmin*ones(nx,1);
    end
    if prod(size(xmax))==1,
        xmax=xmax*ones(nx,1);
    end
    A=[A;eye(nx);-eye(nx)];
    B=[B;xmax;-xmin];
    if ~exist('solver'),
        solver=[];
    end
    [A,B]=polyreduce(A,B,lptype(solver));
end

if isa(A,'cell'),
    is_Vpoly=1;
    V=A;
    nx=length(V{1});
    if nargin>=2 & ~isempty(B),
        c=B;
    else
        c=rand(1,3);
    end
    if nargin>=3,
        shaded=c;
    else
        shaded=shaded_default;
    end
else
    is_Vpoly=0;
    
    nB=size(B,1);
    [nA,nx]=size(A);
    if nB~=nA,
        error('A and B must have the same number of rows.')
    end
    if nA<1,
        error('Cannot plot the whole plane.')
    end        
    if nargin<3 | isempty(c),
        c=rand(1,3);
    end
    if nargin<4,
        shaded=shaded_default;
    end
end
if isempty(shaded),
    shaded=shaded_default;
end

if nx==0,
    if nargout>0,
        V={};
        if nargout>1,
            handle=[];
        end
    end
    return
end


if nx~=2,
    error('Can only plot 2D polyhedra')
end

if is_Vpoly,
    
    nV=length(V);
    for i=1:nV,
        W{i}=V{i}-V{1};
    end
    I=order(W);
    V=V(I);
    
else
    
    % Order normal vectors
    nV=nA;
    
    for i=1:nA,
        aux=A(i,:)';
        N{i}=aux/norm(aux);
    end
    I=order(N);
    I=[I;I(1)]; % Duplicates the first, to compute also the last vertex
    for i=1:nA,
        j=I(i);
        A1=A(j,:);
        B1=B(j);
        A2=A(I(i+1),:);
        B2=B(I(i+1));
        
        % Find the intersection of the two lines
        
        AA=[A1;A2];
        if rank(AA)<2,
            %if ~isfinite(xy),
            aux='Either the polyhedral H-representation is not minimal (two lines are parallel)';
            aux2='or the polyhedron is unbounded (with two parallel lines). You can try setting';
            aux3='bounds XMIN,XMAX, type "help polyplot" for details.';
            error(sprintf('%s\n%s\n%s\n',aux,aux2,aux3));
        end
        
        xy=AA\[B1;B2];
        
        V{i}=xy;
    end
end

x=zeros(nV,1);
y=zeros(nV,1);
for i=1:nV,
    x(i)=V{i}(1);
    y(i)=V{i}(2);
end
hold on

%plot(x,y,'Color',c1);
%handle=fill(x,y,c2);
handle=patch(x,y,c);

if exist('shaded') & ~isempty(shaded),
    if shaded==0,
        % Only plot border of polytope
        set(handle,'FaceColor','none','EdgeColor',c*.5,'EdgeAlpha',shaded);
    else
        set(handle,'FaceAlpha',shaded,'EdgeColor',c*.5,'EdgeAlpha',shaded);
    end
end


%plot(x,y,'*');

hold off
drawnow

if nargout==0,
    clear V handle
end


function I=order(V);
% Order the vectors in V by increasing phase, and returns the
% vector of indices I

n=length(V);

arg=zeros(n,1);
for i=1:n,
    v=V{i};
    arg(i)=atan2(v(2),v(1));
end

[arg,I]=sort(arg);
