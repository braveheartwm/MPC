function [xn, d, z, y] = cruisecontrolsim(x, u, params)
% [xn, d, z, y] = cruisecontrolsim(x, u, params)
% simulates the hybrid system one step ahead.
% Parameters:
%   x: current state
%   u: input
%   params: structure containing values for
%           all symbolic parameters
% Output:
%   xn: state in the next timestep
%   u: output
%   d, z: Boolean and real auxiliary variables
%
% HYSDEL 2.0.5 (Build: 20020910)
% Copyright (C) 1999-2002  Fabio D. Torrisi
% 
% HYSDEL comes with ABSOLUTELY NO WARRANTY;
% HYSDEL is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public
% License as published by the Free Software Foundation; either
% version 2 of the License, or (at your option) any later version.
if ~exist('x', 'var')
	error('error:  current state x not supplied');
end
x=x(:);
if ~all (size(x)==[2 1])
	error('error: state vector has wrong dimension');
end
if ~exist('u', 'var')
	error('error: input u not supplied');
end
u=u(:);
if ~all (size(u)==[8 1])
	error('error: input vector has wrong dimension');
end

d = zeros(4, 1);
z = zeros(18, 1);
xn = zeros(2, 1);
y = zeros(0, 1);

if (u(2) < 0) | (u(2) > 8700.6)
	error('variable F_brake is out of bounds');
end
if (u(3) < 0) | (u(3) > 1)
	error('variable gear1 is out of bounds');
end
if (u(4) < 0) | (u(4) > 1)
	error('variable gear2 is out of bounds');
end
if (u(5) < 0) | (u(5) > 1)
	error('variable gear3 is out of bounds');
end
if (u(6) < 0) | (u(6) > 1)
	error('variable gear4 is out of bounds');
end
if (u(7) < 0) | (u(7) > 1)
	error('variable gear5 is out of bounds');
end
if (u(8) < 0) | (u(8) > 1)
	error('variable gearR is out of bounds');
end
if (x(1) < 0) | (x(1) > 10000)
	error('variable position is out of bounds');
end
if (x(2) < -13.8888888888889) | (x(2) > 61.1111111111111)
	error('variable speed is out of bounds');
end
if (u(1) < -200) | (u(1) > 200)
	error('variable torque is out of bounds');
end

% Fe1 = {IF gear1 THEN torque / speed_factor * Rgear1};
if u(3)
	within(((u(1)) / (0.0818712052216151)) * (3.7271), -9104.78840493726, 9104.78840493726, 90);
	z(2) = ((u(1)) / (0.0818712052216151)) * (3.7271);
else
	within(0, 0, 0, 90);
	z(2) = 0;
end

% Fe2 = {IF gear2 THEN torque / speed_factor * Rgear2};
if u(4)
	within(((u(1)) / (0.0818712052216151)) * (2.048), -5002.97997191154, 5002.97997191154, 91);
	z(3) = ((u(1)) / (0.0818712052216151)) * (2.048);
else
	within(0, 0, 0, 91);
	z(3) = 0;
end

% Fe3 = {IF gear3 THEN torque / speed_factor * Rgear3};
if u(5)
	within(((u(1)) / (0.0818712052216151)) * (1.321), -3227.01979633552, 3227.01979633552, 92);
	z(4) = ((u(1)) / (0.0818712052216151)) * (1.321);
else
	within(0, 0, 0, 92);
	z(4) = 0;
end

% Fe4 = {IF gear4 THEN torque / speed_factor * Rgear4};
if u(6)
	within(((u(1)) / (0.0818712052216151)) * (0.971), -2372.01833629205, 2372.01833629205, 93);
	z(5) = ((u(1)) / (0.0818712052216151)) * (0.971);
else
	within(0, 0, 0, 93);
	z(5) = 0;
end

% Fe5 = {IF gear5 THEN torque / speed_factor * Rgear5};
if u(7)
	within(((u(1)) / (0.0818712052216151)) * (0.756), -1846.80315369391, 1846.80315369391, 94);
	z(6) = ((u(1)) / (0.0818712052216151)) * (0.756);
else
	within(0, 0, 0, 94);
	z(6) = 0;
end

% FeR = {IF gearR THEN torque / speed_factor * RgearR};
if u(8)
	within(((u(1)) / (0.0818712052216151)) * (-3.545), -8659.94335958322, 8659.94335958322, 95);
	z(7) = ((u(1)) / (0.0818712052216151)) * (-3.545);
else
	within(0, 0, 0, 95);
	z(7) = 0;
end

% w1 = {IF gear1 THEN speed / speed_factor * Rgear1};
if u(3)
	within(((x(2)) / (0.0818712052216151)) * (3.7271), -632.276972565088, 2782.01867928639, 97);
	z(9) = ((x(2)) / (0.0818712052216151)) * (3.7271);
else
	within(0, 0, 0, 97);
	z(9) = 0;
end

% w2 = {IF gear2 THEN speed / speed_factor * Rgear2};
if u(4)
	within(((x(2)) / (0.0818712052216151)) * (2.048), -347.429164716079, 1528.68832475075, 98);
	z(10) = ((x(2)) / (0.0818712052216151)) * (2.048);
else
	within(0, 0, 0, 98);
	z(10) = 0;
end

% w3 = {IF gear3 THEN speed / speed_factor * Rgear3};
if u(5)
	within(((x(2)) / (0.0818712052216151)) * (1.321), -224.098596967745, 986.033826658076, 99);
	z(11) = ((x(2)) / (0.0818712052216151)) * (1.321);
else
	within(0, 0, 0, 99);
	z(11) = 0;
end

% w4 = {IF gear4 THEN speed / speed_factor * Rgear4};
if u(6)
	within(((x(2)) / (0.0818712052216151)) * (0.971), -164.723495575836, 724.783380533681, 100);
	z(12) = ((x(2)) / (0.0818712052216151)) * (0.971);
else
	within(0, 0, 0, 100);
	z(12) = 0;
end

% w5 = {IF gear5 THEN speed / speed_factor * Rgear5};
if u(7)
	within(((x(2)) / (0.0818712052216151)) * (0.756), -128.250219006522, 564.300963628695, 101);
	z(13) = ((x(2)) / (0.0818712052216151)) * (0.756);
else
	within(0, 0, 0, 101);
	z(13) = 0;
end

% wR = {IF gearR THEN speed / speed_factor * RgearR};
if u(8)
	within(((x(2)) / (0.0818712052216151)) * (-3.545), -2646.09380431709, 601.384955526612, 102);
	z(14) = ((x(2)) / (0.0818712052216151)) * (-3.545);
else
	within(0, 0, 0, 102);
	z(14) = 0;
end

% F = Fe1 + Fe2 + Fe3 + Fe4 + Fe5 + FeR;
z(1) = (((((z(2)) + (z(3))) + (z(4))) + (z(5))) + (z(6))) + (z(7));

% w = w1 + w2 + w3 + w4 + w5 + wR;
z(8) = (((((z(9)) + (z(10))) + (z(11))) + (z(12))) + (z(13))) + (z(14));

% dPWL1 = wPWL1 - w <= 0;
within(((83.7733) - (z(8))) - (0), -7103.4368303842, 4226.64555314836, 82);
if ((83.7733) - (z(8))) - (0) <= 0
	d(1) = 1;
else
	d(1) = 0;
end

% dPWL2 = wPWL2 - w <= 0;
within(((167.5467) - (z(8))) - (0), -7019.6634303842, 4310.41895314836, 83);
if ((167.5467) - (z(8))) - (0) <= 0
	d(2) = 1;
else
	d(2) = 0;
end

% dPWL3 = wPWL3 - w <= 0;
within(((251.32) - (z(8))) - (0), -6935.8901303842, 4394.19225314836, 84);
if ((251.32) - (z(8))) - (0) <= 0
	d(3) = 1;
else
	d(3) = 0;
end

% dPWL4 = wPWL4 - w <= 0;
within(((335.0933) - (z(8))) - (0), -6852.1168303842, 4477.96555314836, 85);
if ((335.0933) - (z(8))) - (0) <= 0
	d(4) = 1;
else
	d(4) = 0;
end

% DCe1 = {IF dPWL1 THEN (aPWL2 - aPWL1) + (bPWL2 - bPWL1) * w};
if d(1)
	within((58.107) + ((-0.6937) * (z(8))), -4927.66066744752, 2932.01748200902, 104);
	z(15) = (58.107) + ((-0.6937) * (z(8)));
else
	within(0, 0, 0, 104);
	z(15) = 0;
end

% DCe2 = {IF dPWL2 THEN (aPWL3 - aPWL2) + (bPWL3 - bPWL2) * w};
if d(2)
	within((93.6543) + ((-0.5589) * (z(8))), -3923.27744187173, 2409.10560228462, 105);
	z(16) = (93.6543) + ((-0.5589) * (z(8)));
else
	within(0, 0, 0, 105);
	z(16) = 0;
end

% DCe3 = {IF dPWL3 THEN (aPWL4 - aPWL3) + (bPWL4 - bPWL3) * w};
if d(3)
	within((41.0913) + ((-0.1635) * (z(8))), -1134.01755631782, 718.450913389757, 106);
	z(17) = (41.0913) + ((-0.1635) * (z(8)));
else
	within(0, 0, 0, 106);
	z(17) = 0;
end

% DCe4 = {IF dPWL4 THEN (aPWL5 - aPWL4) + (bPWL5 - bPWL4) * w};
if d(4)
	within((67.0958) + ((-0.2003) * (z(8))), -1372.50238911596, 896.913112305617, 107);
	z(18) = (67.0958) + ((-0.2003) * (z(8)));
else
	within(0, 0, 0, 107);
	z(18) = 0;
end

% position = position + Ts * speed;
xn(1) = (x(1)) + ((0.5) * (x(2)));

% speed = speed + Ts / mass * (F - F_brake - beta_friction * speed);
xn(2) = (x(2)) + ((0.000490196078431373) * (((z(1)) - (u(2))) - ((25) * (x(2)))));

xn=xn(:);
y=y(:);
z=z(:);
d=d(:);


function within(x, lo, hi, line)
if x<lo | x>hi
	error(['bounds violated at line ', num2str(line), ' in the hysdel source']);
end
