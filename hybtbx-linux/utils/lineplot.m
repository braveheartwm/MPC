function lineplot(a,b,width,color)
% LINEPLOT(a,b,width,color) draw the line a*x=b on the screen (only 2D)
%
%(C) 2003 by A. Bemporad

if nargin<3,
    width=1;
end
if nargin<4,
    color=[0 0 0];
end
a=a(:)';

ax=axis;
epsil=max(ax(2)-ax(1),ax(4)-ax(3))/400*width;
A=[a;-a;eye(2);-eye(2)];
B=[b+epsil;-b+epsil;ax(2);ax(4);-ax(1);-ax(3)];
[A,B,isemptypoly]=polyreduce(A,B);

if ~isemptypoly,
    polyplot(A,B,color)
end