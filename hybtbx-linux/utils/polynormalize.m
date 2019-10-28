function [A1,B1]=polynormalize(A,B,tol);
% POLYNORMALIZE Normalize the coefficients of a polyhedron.
%           [A1,B1]=POLYNORMALIZE(A,B) normalizes the coefficients of the
%           the polytope {x: Ax<=B}. 
%
%           [A1,B1]=POLYNORMALIZE(A,B,tol) only normalize the rows #i where 
%           |B(i)|>tol*max_j|A(i,j)| and |B(i)|>tol
%
% (C) 2000 by A. Bemporad, Zurich, August 22, 2000


if nargin<2,
   error('Input argument missing');
end

if nargin<3,
   tol1=1e-4;
	tol2=1e-4;
else
   tol1=1e-6;
   tol2=tol;
end

for i=1:length(B);
   auxb=B(i);
   auxba=abs(auxb);
   auxA=A(i,:);
   if auxba>tol1*norm(auxA,'inf') & auxba>tol2,
      % normalize
      A(i,:)=auxA/auxba;
      B(i)=auxb/auxba;
   end
end

A1=A;
B1=B;
