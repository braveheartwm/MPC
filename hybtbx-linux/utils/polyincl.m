function [yesno,lpsolved]=polyincl(A1,B1,A2,B2,LPsolver)
%POLYINCL  Inclusion of polytopes {A1 x <= B1}, {A2 x <= B2}.
%
%           [yesno,lpsolved]=POLYINCL(A1,B1,A2,B2,LPsolver) returns
%                    yesno = 1  if {A1 x <= B1} \subseteq {A2 x <= B2}
%                    yesno = 0  otherwise
%
%(C) 2003 by A. Bemporad

if nargin<5,
    LPsolver=[];
end

m2=size(A2,1);
m1=size(A1,1);
n=size(A2,2);
yesno=1;
i=1;
xopt=zeros(n,1);
lpsolved=0;

while (i<=m2) & yesno,
    xopt=lpsol(-A2(i,:)',A1,B1,[],[],xopt,0,0,LPsolver);
    lpsolved=lpsolved+1;
    f=A2(i,:)*xopt-B2(i);
    if f>0, %{A2(i,:) x - B2(i) <=0} intersects {A1 x <= B1}
        yesno=0;
    end
    i=i+1;
end
