function plotcar(thetitle,X,U,Z,T,XR);

aPWL1=0;
bPWL1=1.3281;

if nargin<6,
    XR=[];
end

set(gcf,'position',[99   207   836   447]);

subplot(241)
plot(T,X(:,2)*3.6);
if ~isempty(XR),
    hold on
    plot(T,XR(:,1)*3.6,'g');
end
ylabel('Vehicle Speed (km/h)')
xlabel('Time');
grid

subplot(242)
plot(T,U(:,3)+2*U(:,4)+3*U(:,5)+4*U(:,6)+5*U(:,7)-U(:,8));
ylabel('Gear')
xlabel('Time');
grid



subplot(243)
%(aPWL1+bPWL1*w+DCe1+DCe2+DCe3+DCe4)
plot(T,U(:,1)./(aPWL1+bPWL1*Z(:,8)+Z(:,15)+Z(:,16)+Z(:,17)+Z(:,18)));
ylabel('Fraction of Max Torque (Nm)');
xlabel('Time');
grid

subplot(244)
plot(T,U(:,2)/1000);
ylabel('Brakes (kN)')
xlabel('Time');
grid

subplot(245)
plot(T,X(:,1)/1000);
ylabel('Position (km)');
xlabel('Time');
grid

subplot(246)
plot(T,Z(:,8)*60/2/pi);
ylabel('Engine Speed (rpm)');
xlabel('Time');
grid

subplot(247)
plot(T,U(:,1));
ylabel('Torque (Nm)');
xlabel('Time');
grid

subplot(248)
plot(T,U(:,1).*Z(:,8)/1000);
ylabel('Power (kW)')
xlabel('Time');
grid

set(gcf,'Name',thetitle);
drawnow