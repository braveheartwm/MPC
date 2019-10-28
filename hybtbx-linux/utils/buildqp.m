%  BUILD Builds matrices for solving constrained linear quadratic optimal control problems
% 
%  [Q,C,G,W,S]=build(model,Q,R,Nu,Ny,Ncu,Ncy,...
%    umin,umax,dumin,dumax,ymin,ymax,soft,tracking,useLQ,KG,P,rho,yzerocon)
% 
%  determine the matrices of the mpQP problem
% 
%  min  .5*x'Qx+th'*C'*x
% 
%  s.t. G*x <= W + S*th
% 
%  corresponding to the following MPC formulation in state-space and w/tracking:
%  =========================================
%  If soft=0: (hard constraints)
% 
%  min J=x'(t+N_y|t) P x(t+N_y|t) +
%        \sum_{k=0}^N_y-1  x'(t+k|t) Q x(t+k|t) + u'(t+k) R u(t+k)
% 
%  s.t. ymin <= y(t+k|t)<=ymax, k=1,...,Ncy
%       umin <= u(t+k)  <=umax, k=0,...,Ncu
%       u(t+k)=KG*x(t+k), k>=Nu
% 
%       x(t+1)=model.A x(t)+model.B u(t)
%         y(t)=model.C x(t)+model.D u(t)
% 
%  where model is a discrete-time LTI SS-object.
% 
%  If soft=1: (hard constraints only on inputs u(0),...,u(Nu-1))
% 
%  min J + rho*eps^2
% 
%  s.t. ymin-eps <= y(t+k|t)<=ymax+eps, k=1,...,Ncy
%       umin <= u(t+k)  <=umax, k=0,...,min(Nu-1,Ncu)
%       umin-eps <= u(t+k) <=umax+eps k=Nu,...,Ncu
%       u(t+k)=KG*x(t+k), k>=N_u
% 
% =========================================
%  MPC formulation in State-Space, w/ tracking
% 
%  If soft=0: (hard constraints)
% 
%  min J=\sum_{k=0}^N_y-1 (y(t+k|t)-r)' Q (y(t+k|t)-r) + du'(t+k) R du(t+k)
% 
%  s.t. ymin  <= y(t+k|t) <=ymax,  k=1,...,Ncy
%       umin  <= u(t+k)   <=umax,  k=0,...,Ncu
%       dumin <= du(t+k)  <=dumax, k=0,...,Ncu
%       du(t+k)=0,                 k>=N_u
% 
%       x(t+1)=Ax(t)+B(u(t-1)+du(t))
%         y(t)=Cx(t)+D(u(t-1)+du(t))
% 
%  If soft=1: (hard constraints only on inputs u(0),...,u(Nu-1))
% 
%  min J + rho*eps^2
% 
%  s.t. ymin-eps <= y(t+k|t) <=ymax+eps, k=1,...,Ncy
%       umin-eps <= u(t+k)   <=umax+eps  k=Nu,...,Ncu
%       umin     <= u(t+k)   <=umax,     k=0,...,min(Nu-1,Ncu)
%       dumin    <= du(t+k)  <=dumax,    k=0,...,min(Nu-1,Ncu)
%       du(t+k)=0,                       k>=N_u
% 
%  If yzerocon=1, then output constraints are enforced also at prediction time
%  k=0. If yzerocon is a binary vector, then output constraints are enforced
%  selectively.
% 
%  Time-varying models, weights, and limits are supported (see LINCON.M)
% 
%  (C) 2003-2009 by Alberto Bemporad 
