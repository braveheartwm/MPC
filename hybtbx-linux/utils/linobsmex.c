/* Explicit controller + observer for reference tracking - MEX interface

   [u,reg]=linobsmex(y,r,init)

   Compute the control action u given the output measurements y(t) and
   the reference r(t). For regulators to the origin, r is ignored.

   init=1: initialize static variables
       =0: keep current value of static variables

   (C) 2003 by Alberto Bemporad
*/

#include "mex.h"
#include "expconobs.c"

/* Input Arguments */

#define Y_IN    prhs[0]
#define R_IN    prhs[1]
#define INIT_IN prhs[2]


/* Output Arguments */

#define U_OUT   plhs[0]
#define REG_OUT plhs[1]


void mexFunction( int nlhs, mxArray *plhs[],
          int nrhs, const mxArray*prhs[] )

{
    double *u,*reg;
    double *y,*r,*init;

    /* Check for proper number of arguments */

    if (nrhs <3) {
        mexErrMsgTxt("Three input arguments required.");
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

    y = mxGetPr(Y_IN);
    r = mxGetPr(R_IN);
    init = mxGetPr(INIT_IN);

    /* Do the actual computations in a subroutine */
    *reg=(double) expconobs(u,y,r, (int) init[0]);

    return;

}
