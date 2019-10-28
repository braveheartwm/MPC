function [V,handle]=polyplot3(A,B,z0,c1,c2)
% POLYPLOT3  Plot of two dimensional polyhedra in a 3 dimensional space.
%
%           POLYPLOT3(A,B,z0) plots the polyhedron {x,z: Ax<=B, z=z0}. It it
%           assumed that Ax<=B does not have redundant constraints
%           (see POLYREDUCE).
%
%           POLYPLOT(V,z0) plots the polytope obtained by the convex
%           hull of points in the cell array V.
%
%           V=POLYPLOT(A,B,z0) only returns the vertices in cell
%           array V (ordered)
%
%           [V,handle]=POLYPLOT3(A,B,z0) or handle=POLYPLOT(V,z0)
%           also returns the handle to the PATCH object
%
%           POLYPLOT3(A,B,z0,c1,c2), POLYPLOT(V,z0,c1,c2) draws the polyhedron with
%           color border c1 and fill color c2=[r g b].
%
% (C) 2000 by A. Bemporad, Zurich, March 30, 2000
% (C) 1999 by A. Bemporad, Zurich, July 2, 1999

if nargin<1,
   error('Empty arguments');
end

if isa(A,'cell'),
   is_Vpoly=1;
   V=A;
   nx=length(V{1});
   if nargin>2,
      aux=B;
      if nargin>3,
         c2=c1;
      else
         c2=abs(1-aux);
      end
      c1=aux;
   else
      c1=[1 0 1];
		c2=abs(1-c1);
   end
   if nargin==1,
      z0=0;
   end
else
   is_Vpoly=0;
   
   nB=size(B,1);
	[nA,nx]=size(A);
	if nB~=nA,
   	error('A and B must have the same number of rows.')
	end
	if nargin<4,
   	c1=[1 0 1];
	end
	if nargin<5,
   	c2=abs(1-c1);
	end
   if nargin==2,
      z0=0;
   end
   
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
      xy=[A1;A2]\[B1;B2];
      if ~isfinite(xy),
         error('The polyhedral H-representation is not minimal, two lines are parallel.')
		end
      
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

z=z0*ones(size(x));
plot3(x,y,z,'Color',c1);
% plot3(x,y,z);
handle=fill3(x,y,z,c2);
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
