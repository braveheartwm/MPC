function [A3,B3,how]=polyunion(A1,B1,A2,B2,check,tol,checkmin,lpsolver)
% POLYUNION Usage: [A3,B3,how]=polyunion(A1,B1,A2,B2)
%
% Given the polyhedra P1={A1*x<=B1}, P2={A2*x<=B2}, such that their union
% is a convex polyhedron P3={A3*x<=B3}, their intersection has an empty
% interior, and (A1,B1) (A2,B2) do not have redundant constraints,
% returns P3. If the hypothesis on P1,P2 is satisfied, then how='ok'
% otherwise, how='fault'.
%
%                  [A3,B3,how]=polyunion(A1,B1,A2,B2,check)
%
% If check is omitted, no check on minimality of (A1,B1) (A2,B2)
% and convexity of the union is performed. If check=1, (A1,B1) (A2,B2)
% are first reduced to a minimal set of inequalities, and convexity
% of the union is checked.
%
%                  [A3,B3,how]=polyunion(A1,B1,A2,B2,check,tol)
%
% also defines the tolerance used to detect equal rows of matrices.
%
%                  [A3,B3,how]=polyunion(A1,B1,A2,B2,check,tol,checkmin)
%
% If checkmin=1, do not check for minimality of A1,B1 and A2,B2. Default is 0
%
%                  [A3,B3,how]=polyunion(A1,B1,A2,B2,check,tol,checkmin,lpsolver)
%
% (C) 2003 by A. Bemporad
%    (code based on an idea by A. Bemporad and F.D. Torrisi)

if nargin<4,
   error('Not enough input arguments')
end

if nargin<5|isempty(check),
   check=1;
end   

if nargin<6|isempty(tol),
	tol=1e-3; % Tolerance
end

if nargin<7|isempty(checkmin),
   checkmin=0; % Must check for minimality 
end

if nargin<8 | isempty(lpsolver),
   lpsolver=3; % Default: GLPK
end

if ~checkmin,
   [A1,B1]=polyreduce(A1,B1,lpsolver);
   [A2,B2]=polyreduce(A2,B2,lpsolver);
end   


nB1=size(B1,1);
[nA1,nx1]=size(A1);
if nB1~=nA1,
    error('A1 and B1 must have the same number of rows.')
end

nB2=size(B2,1);
[nA2,nx2]=size(A2);
if nB2~=nA2,
    error('A2 and B2 must have the same number of rows.')
end

if nx1~=nx2,
    error('A1 and A2 must have the same number of columns.')
end

% Look for pairs of rows which are opposite in sign

pairs=0;
same=0;
i2=[];
j2=[];

how='ok';
A3=[];
B3=[];
for i=1:nA1,
   for j=1:nA2,
      %aux1=abs(B1(i));
      %if aux1>tol,
      %   r1=[A1(i,:)/aux1,B1(i)/aux1];
      %else
      %   r1=[A1(i,:),B1(i)];
      %end
      aux=[A1(i,:) B1(i)];
      aux1=max(abs(aux));
      r1=aux/aux1;

      %aux2=abs(B2(j));
      %if aux2>tol,
	   %  r2=[A2(j,:)/aux2,B2(j)/aux2];
      %else
      %   r2=[A2(j,:),B2(j)];
      %end
      aux=[A2(j,:) B2(j)];
      aux1=max(abs(aux));
      r2=aux/aux1;
      
      if abs(r1+r2)<tol,
         pairs=pairs+1;
         i1=i;
         j1=j;
         if pairs>1,
            % The union of P1 and P2 is not convex
            how='fault';
            return
         end
      end
      if abs(r1-r2)<tol,
         same=same+1;
         i2=[i2,i];
         j2=[j2,j];
		end      
   end
end

if pairs~=1,
   % The union of P1 and P2 is not convex, or P1,P2 are not disjoint
   how='fault';
   return
end

auxA11=A1(i1,:);
auxB11=B1(i1,:);
auxA12=A1(i2,:);
auxB12=B1(i2,:);
A1([i2,i1],:)=[]; % \tilde A1
B1([i2,i1],:)=[]; % \tilde B1

auxA21=A2(j1,:);
auxB21=B2(j1,:);
auxA22=A2(j2,:);
auxB22=B2(j2,:);
A2([j2,j1],:)=[]; % \tilde A2
B2([j2,j1],:)=[]; % \tilde B2

A3=[A1;A2;.5*(auxA12+auxA22)];
B3=[B1;B2;.5*(auxB12+auxB22)];

if ~check,
   return   
end

x=zeros(nx1,1); % Initialize x

for i=1:length(B2),
   
   %[x,dummy,how2]=lpsolve(-A2(i,:),[A1;auxA11;auxA12],[B1;auxB11;auxB12],x,1);
   [x,dummy,how2]=lpsol(-A2(i,:),[A1;auxA11;auxA12],[B1;auxB11;auxB12],[],[],x,[],[],lpsolver);
	M=A2(i,:)*x-B2(i);
   if strcmp(how2,'infeasible'),
      % (A1,B1) is an empty polyhedron
      how='fault';
      return
   elseif (strcmp(how2,'ok')&(M>tol))|strcmp(how2,'unbounded'),
	   % The union of P1 and P2 is not convex, or P1,P2 are not disjoint
       how='fault';
      return
   end %either M=infty (unbounded) or M<=0   
end

for j=1:length(B1),
   %[x,dummy,how2]=lpsolve(-A1(j,:),[A2;auxA21;auxA22],[B2;auxB21;auxB22],x,1);
   [x,dummy,how2]=lpsol(-A1(j,:),[A2;auxA21;auxA22],[B2;auxB21;auxB22],[],[],x,[],[],lpsolver);
   M=A1(j,:)*x-B1(j);
   if strcmp(how2,'infeasible'),
      % (A2,B2) is an empty polyhedron
             how='fault';
      return
   elseif (strcmp(how2,'ok')&(M>tol))|strcmp(how2,'unbounded'),
      % The union of P1 and P2 is not convex, or P1,P2 are not disjoint
             how='fault';
      return
   end %either M=infty (unbounded) or M<=0   
end

%%[A3,B3]=polyreduce(A3,B3,tol/100);
[A3,B3]=polyreduce(A3,B3,lpsolver,tol/100);