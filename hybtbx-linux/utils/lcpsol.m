function [w,z,how] = lcpsol(M,q,solver)
%LCPSOL Solve Linear Complementary Problems via Quadratic Programming 
%    [w,z,how]=LCP_QP(M,q,solver) solves the LCP problem:
% 
%                      w - M*z  = q                                                 
%                      w(i)z(i) = 0                                                 
%                      w >= 0, z >= 0                                               
%
%    via the QP problem
%
%                      min  z'(Mz+q)
%                      s.t. z>=0
%
%   given that the KKT for QP are:
%      M*z+q-w=0
%      z(i)*w(i)=0
%      z>=0
%      w>=0
%
%    QPSOL.M is used to solve QP.
%
%    The algorithm requires that M=M'>0 to work properly.
%
% Type "help qptype" for a list of available solvers

% (C) 2001-2007 by Alberto Bemporad

[n,m]=size(M);
if m~=n,
    error('M must be square');
end

q=q(:);
if length(q)~=n,
    error('M and q must have the same number of rows');
end

if nargin<3,
   solver=[];
end

[z,w,how]=qpsol(M,q,-eye(n),zeros(n,1),[],[],zeros(n,1),solver);

%w=M*z+q;