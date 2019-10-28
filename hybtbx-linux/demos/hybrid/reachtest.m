ts=0.2; % Sampling time
S=mld('reachtest',ts);
N=5;
Xf.A=[eye(5);-eye(5)];
Xf.b=[1 1 1 1 1 1 -.5 1 0 0]';
X0.A=[eye(5);-eye(5)];
X0.b=[.1 .1 .1 1 1 .1 -.1 .1 0 0]';

tic
[flag,x0,U,xf,X,T,D,Z,Y,reachtime]=reach(S,[1 N],Xf,X0);
toc

switch flag
    case 1,
        % Add final state in plot
        T=[T;T(end)+S.ts];
        X=[X;xf'];
        
        for i=1:S.nx,
            subplot(S.nx,1,i);
            plot(T,X(:,i),T,X(:,i),'*');
            ylabel(sprintf('x_%d',i))
            grid
        end
        xlabel('time (s)')
        subplot(S.nx,1,1)
        title('State trajectory')
        set(gcf,'position',[168    74   359   611]);
        
    case 0
        disp('Xf is not reachable from X0');
    case -1
        disp('Xf is reachable from X0, but cannot verify the counterexample');
end
