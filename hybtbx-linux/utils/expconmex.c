/* Explicit controller - State Feedback - MEX interface

   [u,reg]=expcontrol(th)

   Compute the optimal control action u given the parameter vector th(t).
   For linear regulators, th(t)=x(t) is the current state. 
   For hybrid regulators, th(t)=[x(t);r(t)] also contains the reference signals.

   (C) 2003 by Alberto Bemporad
*/

#include "mex.h"
#include "expcon.c"

/* Input Arguments */

#define TH_IN    prhs[0]


/* Output Arguments */

#define U_OUT   plhs[0]
#define REG_OUT plhs[1]


void mexFunction( int nlhs, mxArray *plhs[],
          int nrhs, const mxArray*prhs[] )

{
    double *u,*reg;
    double *th;

    /* Check for proper number of arguments */

    if (nrhs <1) {
        mexErrMsgTxt("An input argument is required (parameter vector th(t)).");
    }
    else if (nlhs > 2) {
        mexErrMsgTxt("Too many output arguments.");
    }


    /* Create a matrix for the return argument */
    U_OUT = mxCreateDoubleMatrix(EXPCON_NU, 1, mxREAL);
    REG_OUT = mxCreateDoubleMatrix(1, 1, mxREAL);

    /* Assign pointers to the various parameters */
    u = mxGetPr(U_OUT);
    reg = mxGetPr(REG_OUT);

    th = mxGetPr(TH_IN);

    /* Do the actual computations in a subroutine */
    *reg=(double) expcon(u,th);

    return;

}
