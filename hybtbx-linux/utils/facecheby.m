function [r,x,how]=facecheby(A,B,index,lpsolver);
% [r,x,how]=facecheby(A,B,index,lpsolver);
%
% Given the polyhedron P={Ax<=B}, returns the center x and the radius r of the
% largest ball inside the facet A(index)*x=b(index).
%
% (C) 2003 by A. Bemporad, Siena, September 29, 2003

[q,n]=size(A);

if nargin<4,
    lpsolver=[]; %use default LP solver in lpsol
end
eqA=A(index,:);
eqB=B(index);
A=A([1:index-1,index+1:q],:);
B=B([1:index-1,index+1:q]);

N=1; % one equality constraint
display=[];

Echeb=zeros(q-1,1);
neqA=eqA*eqA';
for i=1:q-1,
    Ai=A(i,:);
    aux=Ai*eqA'/neqA;
    Echeb(i)=norm(Ai-aux*eqA);
    %    B(i)=B(i)-aux*eqB;
end

if lpsolver==3,
   VUB=1e6*ones(n+1,1); % To prevent GLPKMEX return xopt=0 when problem is unbounded
   VLB=-VUB;
else
   VUB=[];
   VLB=[];
end


[xopt,dummy,how]=lpsol([zeros(n,1);-1],[eqA,0;A,Echeb],[eqB;B],VLB,VUB,[],N,display,lpsolver);


r=xopt(n+1); % Radius of the ball
x=xopt(1:n); % Center of the ball
