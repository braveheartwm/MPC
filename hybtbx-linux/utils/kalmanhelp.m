% KALMAN Design Kalman filter for constrained optimal controllers
%
% KALMAN(CON,Q,R) design a state observer for the linear model 
% (A,B,C,D)=CON.model which controller CON is based on, 
% using Kalman filtering techniques. The resulting observer is stored
% in the 'Observer' field of the controller object.
% The controller object can be either of class LINCON or EXPCON.
%
% Q is the covariance matrix of state noise, R is the covariance matrix of
% output noise.
%
% Kest=KALMAN(CON,Q,R) also return the state observer as an LTI object.
%
% Kest receives u[n] and y[n] as inputs (in this order), and provides
% the best estimated state x[n|n-1] of x[n] given the past measurements 
% y[n-1], y[n-2],...
%
%      x[n+1|n] = Ax[n|n-1] + Bu[n] + L(y[n] - Cx[n|n-1] - Du[n])
%
% Kest=KALMAN(CON,Q,R,ymeasured) assumes that only the outputs specified
% in vector ymeasured are measurable outputs. In this case, R is a
% nym-by-nym matrix, where nym is the number of measured outputs.
%
% [Kest,M]=KALMAN(CON,Q,R,ymeasured) also returns the gain M which allows
% computing the measurement update
%
%       x[n|n]  = x[n|n-1] + M(y[n] - Cx[n|n-1] - Du[n])
%
% For time-varying prediction models, the first model CON.model{1} is used
% to build the Kalman filter, as it is the model of the process for the
% current time step.
%
% See also KALMDESIGN, LINCON, EXPCON.