function [At,Bt,isemptypoly,keptrows,lpsolved,x0]=polyreduce(A,B,solver,removetol,checkempty,x0,zerotol)
%POLYREDUCE Given a polyhedron Ax<=B, returns an equivalent polyhedron 
%               At x<=Bt by eliminating redundant constraints
%
% [At,Bt,isemptypoly,keptrows,lpsolved,x0]=polyreduce(A,B,solver,removetol,checkempty)
%
% At,Bt        = reduced polyhedron
% isemptypoly  = 1 if (A,B) is empty
% keptrows     = rows of (A,B) kept in (At,Bt)
% lpsolved     = # of LP solved
% x0           = a point in (A,B) (x0=NaN if (A,B) is empty)
% zerotol      = if norm(A(i,:),'inf')<zerotol, it is considered a row of zeros
%
%(C) 2003 by A. Bemporad, September 29, 2003
%(C) 2001 by A. Bemporad, 12/7/2001

[q,n]=size(A);

if q<2,
   % Only one (or none) facet inequality
   At=A;
   Bt=B;
   isemptypoly=0;
   keptrows=(1:q)';
   lpsolved=0;
   if q==0,
      x0=zeros(n,1);
   else
      x0=rand(n,1);
      if A*x0>B,
         x0=x0-2*A'*(A*x0-B)/(A*A'); % symmetrical with respect to the hyperplane
      end
   end
   return
end


k=1;

keptrows=(1:length(B))';
lpsolved=0;
At=A;
Bt=B;

if nargin<3|isempty(solver),
   solver=3; %use GLPK
end
if nargin<4|isempty(removetol),
   removetol=1e-10; % Nonnegative tolerance to decide if a constraint is redundant
end
if nargin<5|isempty(checkempty),
   checkempty=1;
end
if nargin<6|isempty(x0),
   x0=zeros(n,1);
end
if nargin<7|isempty(zerotol),
   zerotol=1e-8;
end


% Check for rows of the type 0*x<=b
i0=find(sum(abs(At)')'<=zerotol); % 0*x
j0=find(Bt(i0)<-zerotol);         % 0*x<=b with b<0
if ~isempty(j0),
    isemptypoly=1;
    x0=NaN*ones(n,1);
    lpsolved=0;
    keptrows=(1:q)';
    At=A;
    Bt=B;
    return
end

% Remove rows of the type 0*x<=b
At(i0,:)=[];
Bt(i0)=[];
keptrows(i0)=[];

if isempty(Bt),
    % No more rows left!
    isemptypoly=0;
    return
end    

if checkempty,
   % Determine if the polyhedron is empty
   [xopt,dummy,how]=lpsol(zeros(n,1),At,Bt,[],[],zeros(n,1),[],[],solver);
   lpsolved=lpsolved+1;
   if strcmp(how,'infeasible'),
      isemptypoly=1;
      x0=NaN*ones(n,1);
      return
   end
   x0=xopt; % Use this for a warm start for the following LP's
end % otherwise, it assumes that the polyhedron is not empty

isemptypoly=0;

j=1;
h=0;

% fprintf('Reducing')
while j<=length(Bt),
   h=h+1;
   f=At(j,:);
   g=Bt(j);
   ii=[1:j-1,j+1:length(Bt)];
   if ~isempty(ii),
       [xopt,dummy,how]=lpsol(-f,At(ii,:),Bt(ii),[],[],x0,[],[],solver);
       val=f*xopt-g;
       lpsolved=lpsolved+1;
   else
       % There's only one constraint left !
       how='ok';
       val=1e6;
   end
   if strcmp(how,'unbounded')|(val>removetol),
       % Leave the constraint
      j=j+1;
      %elseif strcmp(how,'infeasible')
      %   %error('The polyhedron Ax<=B is empty')
   else 
      %disp(sprintf('Constraint #%d DELETED!',j));
      At(j,:)=[];
      Bt(j)=[];
      keptrows(j)=[];
   end
   % fprintf('.');
end
% fprintf('\n');
