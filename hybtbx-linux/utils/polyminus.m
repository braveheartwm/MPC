function [Acell,Bcell,disjoint,LPs]=polyminus...
    (A1,B1,A2,B2,LPsolver,check,reduce,Aint,Bint)
% POLYMINUS  Given two polytopes P1={A1 x <= B1}, P2={A2 x <= B2}, computes P3=P1\setminus P2.
% If P3 is nonconvex, it's is partitioned into convex sets. 
%
% [Acell,Bcell,disjoint,signature,lpsolved]=POLYMINUS(...
%         A1,B1,A2,B2,LPsolver,check,reduce,Aint,Bint) 
%
% computes the cell array Acell,Bcell containing the convex sets. 
% 
% disjoint=1 if P1 and P2 do not intersect. In this case P3=P1,
% Acell{1},Bcell{1}=P3 (if P1 was not in minimal representation, also P3
% will be)
%
% If check is 0 (default:0), no check on minimality of (A1,B1) (A2,B2)
% is performed. If check=1, (A1,B1) (A2,B2) are first reduced to a minimal 
% set of inequalities, and convexity of the union is checked.
%
% If reduce is 0 (default:1), no check on minimality of the output polyhedra is 
% performed. 
%
% Aint,Bint define the intersection of A1,B1,A2,B2. If provided, the
% intersection is non recomputed.
%
% P2 includes P1, then Acell,Bcell will be empty.

% (C) 2003 by A. Bemporad

VERBOSE=0; % Plot polyhedra (only 2D)

if nargin<5,
    LPsolver=[];
end
if nargin<6|isempty(check),
    check=0;
end
if nargin<7|isempty(reduce),
    reduce=1;
end

LPs=0;

if nargin<8,
    A=[A1;A2];
    B=[B1;B2];
    
    [A,B,isemptysec,keptrows,lpsolved,x0]=polyreduce(A,B,LPsolver);
    LPs=LPs+lpsolved;
else
    A=Aint;
    B=Bint;
    isemptysec=0;
end
if VERBOSE,
    polyplot(A,B,[1 0 1]);
end

if check,
    [A1,B1,dummy,dummy,lpsolved]=polyreduce(A1,B1,LPsolver);
    LPs=LPs+lpsolved;
    [A2,B2,dummy,dummy,lpsolved]=polyreduce(A2,B2,LPsolver);
    LPs=LPs+lpsolved;
end

disjoint=0;
if isemptysec,
    disjoint=1;
    Acell{1}=A1;
    Bcell{1}=B1;
    return
end

i=0;
Acell={};
Bcell={};

[N,n]=size(A1);
M=size(A2,1);

% In order to minimize the number of resulting pieces, orders the hyperplane
% A2(j)*x=B2(j) by Chebychev radius of [A1;-A2(j)]*x<=[B1;-B2(j)]

qC=N+1;
xlam0=zeros(n+1,1); % Initial guess
ECheb=zeros(qC,1);
rcheby=zeros(M,1);
for j=1:M,
    % Compute the Chebychev center x and radius r of the largest Euclidean ball
    % contained in the region. Note that r indicates how 'flat' is P (r<0 if P is empty).
    At=[A1;-A2(j,:)];
    Bt=[B1;-B2(j,:)];
    
    for jj=1:qC,
        ECheb(jj)=norm(At(jj,:));
    end
    
    % Find Chebychev center and radius, without intersecting with the box thmin<=th<=thmax:
    [xopt,dummy,how]=lpsol(-[zeros(n,1);1],[At,ECheb],Bt,[],[],xlam0,[],[],LPsolver);
    LPs=LPs+1;
    rcheby(j)=xopt(n+1);
end

[rcheby,ii]=sort(-rcheby); % Sort in descending order
rcheby=-rcheby;
A2=A2(ii,:);
B2=B2(ii,:);

A=A1;
B=B1;
for j=1:M,
    
    if VERBOSE,
        lineplot(A2(j,:),B2(j));
    end
    
    At=[A;-A2(j,:)];
    Bt=[B;-B2(j,:)];
    
    % Determine if the polyhedron is empty
    if rcheby(j)<=0,
        isemptysec=1;
    else
        isemptysec=0;
        if j>1,
            % Still the intersection may be empty
            [xdummy,dummy,how]=lpsol(zeros(n,1),At,Bt,[],[],[],[],[],LPsolver);
            isemptysec=strcmp(how,'infeasible');
            lpsolved=1;
            LPs=LPs+lpsolved;
        end
    end
    
    if ~isemptysec,
        % For sure, [At,Bt] does not coincide with [A,B], otherwise P1 P2 would be disjoint 
        % because there would be a separating hyperplane
        i=i+1;
        
        if reduce,
            [At,Bt,isemptysec,keptrows,lpsolved]=polyreduce(At,Bt,LPsolver);
            LPs=LPs+lpsolved;
        end
        
        Acell{i}=At; 
        Bcell{i}=Bt;
        if VERBOSE,
            polyplot(At,Bt,rand(1)*([1 0 0]*(h==1)+[0 0 1]*(h==2)));
        end
        A=[A;A2(j,:)];
        B=[B;B2(j,:)];
    end
end