% EXP2MLD convert the PWA system resulting from an explicit linear MPC controller
%    in closed-loop with nominal prediction model to hybrid MLD form
% 
%    S=exp2mld(expcon) generates the MLD system S that models the closed-loop system 
%    
%        x(k+1)=A*x(k)+B*f(th(k))
%        y(k)=C*x(k)+D*f(th(k)), 
% 
%    where th(k)=[x(k);u(k-1);r(k)] and f(th) is the explicit MPC law
%    defined by 'expcon'.
% 
%    The states of the MLD system S are the states of the linear model x(k)
%    + the previous input u(k-1), the outputs are y(k), the continuous
%    inputs are the reference signals r(k), the binary inputs are the
%    Boolean variables delta(k), with delta_i(k)=1 iff the explicit
%    controller is in regions i, sum(delta_i)=1.
% 
%    S=exp2mld(expcon,hysdelname) specifies the HYSDEL file name <hysdelname>.hys 
%    used for the conversion. By default, hysdelname <expcon>_hybrid_model.hys.
%
%    Other functions named exp2mld
%
%       expcon/exp2mld
