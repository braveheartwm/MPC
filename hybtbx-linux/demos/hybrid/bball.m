Ts=0.05;
g=9.8; % gravity
alpha=0.3;

S=mld('bouncing_ball',Ts);

N=150;
U=zeros(N,0);
x0=[5 0]';

[X,T,D]=sim(S,x0,U);

close all
figure('Name','Simulation of MLD system');
subplot(311)
plot(T,X(:,1),'r',T,X(:,1),'go')
title('Height');
grid
subplot(312)
plot(T,X(:,2),'b')
title('Velocity');
grid
subplot(313)
stairs(T,D);
title('Event variable ''negative''');
grid
set(gcf,'Position',[  328    68   560   626]);

% Get PWA
P=pwa(S);
figure('Name','Equivalent PWA system');
plot(P);
xlabel('height');
ylabel('velocity');

[X,T,I]=sim(S,x0,U);

figure('Name','Simulation of PWA system');
subplot(311)
plot(T,X(:,1),'r',T,X(:,1),'go')
title('Height');
grid
subplot(312)
plot(T,X(:,2),'b')
title('Velocity');
grid
subplot(313)
stairs(T,I);
title('PWA mode');
grid
set(gcf,'Position',[  328    68   560   626]);
