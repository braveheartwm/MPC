% Restore original values
k=0.098;
R=3*k/(4*mud);

[TT,XX,YY]=sim('dryclutchsim');

we=YY(:,3).*YY(:,4)+YY(:,1).*(1-YY(:,4));
wv=YY(:,3).*YY(:,4)+YY(:,2).*(1-YY(:,4));

figure(2)
subplot(211)
plot(TT,we,TT,wv);
grid
title('\omega_e, \omega_v')
subplot(212)
plot(TT,YY(:,9));
grid
title('F_n')

% Compute dissipated energy
EE=(TT(2:end)-TT(1:end-1))*...
    k*.5.*(YY(2:end,1)-YY(2:end,2)+YY(1:end-1,1)-YY(1:end-1,2))*...
    .5.*(YY(2:end,9)+YY(1:end-1,9));
energy=sum(EE);
disp(sprintf('Total dissipated energy: %5.2f', energy));

% Compute acceleration at engagement

% find time t*
i=find(YY(:,1)-YY(:,2)<1e-3);
if isempty(i),
    istar=size(YY,1);
    tstar=+Inf;
else
    istar=i(1);
    tstar=TT(istar);
end
Fnstar=YY(istar,9);
x2dot=((YY(istar-1,1)-YY(istar-1,2))-0)/...
    (TT(istar)-TT(istar-1));

disp(sprintf('Engagement time: %g, Acceleration at engagement: %g, Fn at enagement: %g',tstar,x2dot,Fnstar));
