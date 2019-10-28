clear range options
range.xmax=[2000;2000;2000;2000;2000];
range.xmin=[-4000;-4000;-4000;-4000;-4000];
range.umax=5000;
range.umin=-400;
range.refymin=[-10;-10];
range.refymax=[10;10];

E=expcon(C,range);

texfile='dry_clutch';

Tin0=110;
Tin0dot=250;
Tl0=4.8;
[h,E1]=plotsection(E,[3 4 5 6 7 8],[Tin0,Tin0dot,Tl0,0,0,0],[],0);

% Now E1 is defined over the state space (we, we-vv). Change
% the partition to (we,vv)
M=[1 0;1 -1]; % Transformation matrix [we,vv]=M*[we,we-vv]
E1.H=E1.H*inv(M);  % H*[we,we-vv]=H*inv(M)*[we,vv]
plot(E1);
axis([0 500 0 500]);

switch controller_num
    case 1
        u0=[2000]; %[1140]; %900
    case 2
        u0=[2000]; %[1140]; %900
    case 3
        u0=[1300]; %[1140]; %900
end

title(sprintf('Section with Tin=%5.2f, Tindot=%5.2f, Tl=%5.2f, u=%5.2f, r=[0,0]',...
    Tin0,Tin0dot,Tl0,u0))
axis([0 300 0 300]); %axis([0 150 0 50]);
xlabel('\omega_e');
ylabel('\omega_v');