function [x,u,mode,y]=getfeasible(P);
% GETFEASIBLE Get a feasible initial state x(0) and input u(0) of a PWA system
%
%  [x,u]=GETFEASIBLE(P) attempts at finding a feasible initial state x(0)
%  and input u(0) for the PWA system P. This is done by solving a
%  mixed-integer linear program on the equivalent MLD dynamics.
%
%  [x,u,mode]=GETFEASIBLE(P) also returns the corresponding initial mode
%  i(0).
%
%  [x,u,mode,y]=GETFEASIBLE(P) also returns the corresponding output y(0).
%
% See also MLD/GETFEASIBLE, PWA/UPDATE, PWA/SIM.

%(C) 2003 by Alberto Bemporad

S=evalin('caller',P.mld);
[x,u]=getfeasible(S);

if nargout>=3,
    % Find region where (x,u) lies
    flag=7;
    i=0;
    tol=1e-6;
    nxr=P.nxr;
    nur=P.nur;
    while flag==7 & i<P.nr,
        i=i+1;
        if all(P.Hx{i}*x+P.Hu{i}*u<=P.K{i}+tol),
            flag=1;
            A=[P.A{i};P.LA{i}];
            B=[P.B{i};P.LB{i}];
            f=[P.f{i};P.Lf{i}];
            C=[P.C{i};P.LC{i}];
            D=[P.D{i};P.LD{i}];
            g=[P.g{i};P.Lg{i}];
        end
    end
    if (flag~=7),
        y=C*x(1:nxr)+D*u(1:nur)+g;
        mode=i;
    else 
        error('PWA infeasibility');
    end
end