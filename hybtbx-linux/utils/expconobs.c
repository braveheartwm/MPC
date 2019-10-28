/* Explicit controller + observer for reference tracking

  reg=expconobs(double *u, double *y, double *r, int init)

  Compute the optimal control action u given the output 
  measurements y(t) and the reference r(t).
  For regulators to the origin, r is ignored.

  init=1: reset initial conditions
      =0: keep current value of static variables
  
  The output argument of the function is the region number.

  (C) 2003 by A. Bemporad
*/


#include "expcon.h"
/* #include <stdio.h> */

static int expconobs(double *u, double *y, double *r, int init)

{
    int i,j;
    int iret;
    int i1,i2,num,check,isinside;
    double aux;

    double yest[EXPCON_NYM];  /* current output estimate */
    static double x[EXPCON_NX];      /* current state estimate */
    double theta[EXPCON_NTH]; /* current theta */
    #define xaux theta        /* also use theta for matrix multiplications */
    
    #ifdef EXPCON_TRACKING
        static double u1[EXPCON_NU]; /* previous input */
    #endif
	    
    if (init) {
        /* Initialize previous state x0 */
        for (i=0;i<EXPCON_NX;i++) {
            x[i]=EXPCON_x0[i];
        }
        #ifdef EXPCON_TRACKING
            /* Initialize previous input u1 */
		for (i=0;i<EXPCON_NU;i++) {
                u1[i]=EXPCON_u1[i];
                u[i]=u1[i]; /* this is needed by the SFUNCTION */
		}
        #endif
        iret=-10;
    }
    else {


    /*   % Measurement update of state observer yest=Cm*xk; */

        for (i=0;i<EXPCON_NYM;i++) {
            yest[i]=0;
            for (j=0;j<EXPCON_NX;j++) {
                yest[i]+=EXPCON_Cm[i+j*EXPCON_NYM]*x[j];
            }
            //printf("yest[%d]=%g\n",i,yest[i]);
        }

        /* xk=xk+L*(y-yest);  */

        for (i=0;i<EXPCON_NX;i++) {
            for (j=0;j<EXPCON_NYM;j++) 
                x[i]+=EXPCON_M[i+j*EXPCON_NX]*(y[j]-yest[j]);
            //printf("Measurement update: x[%d]=%g\n",i,x[i]);
        }


        /* define vector theta */
        for (j=0;j<EXPCON_NX;j++) {
            theta[j]=x[j];
            //printf("theta[%d]=%g\n",j,theta[j]);
        }
            
        #ifdef EXPCON_TRACKING
            for (j=0;j<EXPCON_NU;j++) {
                theta[EXPCON_NX+j]=u1[j];
                //printf("theta[%d]=%g\n",EXPCON_NX+j,theta[EXPCON_NX+j]);
            }
            for (j=0;j<EXPCON_NY;j++) {
                theta[j+EXPCON_NX+EXPCON_NU]=r[j];
                //printf("r[%d]=%g\n",j,r[j]);
                //printf("theta[%d]=%g\n",EXPCON_NX+EXPCON_NU+j,theta[EXPCON_NX+EXPCON_NU+j]);
            }
        #endif

        for (i=0;i<EXPCON_NU;i++) {
            #ifdef EXPCON_TRACKING
                u[i]=u1[i];
                //printf("(before) u[%d]=%g\n",i,u[i]);
            #endif
            #ifdef EXPCON_REGULATION
                u[i]=0;
            #endif
        }
        
        #ifdef EXPCON_UNCONSTRAINED
        /* Unconstrained control */

            /* If tracking, uk=uk+expcon.F*th. If regulation, uk=expcon.F*th; */
            for (i=0;i<EXPCON_NU;i++) {
                for (j=0;j<EXPCON_NTH;j++)
                    u[i]+=EXPCON_F[i+j*EXPCON_NU]*theta[j];
                //printf("u[%d]=%g\n",i,u[i]);
            }
            iret=0;
        #endif
        
        #ifdef EXPCON_CONSTRAINED
        
            /* Constrained explicit control */

            i1=0;                /* H(i1:i2,:), K(i1:i2) = current region */
            i2=EXPCON_len[0]-1;
            num=0;
            check=1;

            while ((num<EXPCON_REG) && check) {
                isinside=1;
                while ((i1<=i2) && isinside) {
                    aux=0;
                    for (j=0;j<EXPCON_NTH;j++)
                        aux+=(double)EXPCON_H[i1+j*EXPCON_NH]*theta[j];
                    if (aux>(double)EXPCON_K[i1])
                        isinside=0; /* get out of the loop, theta violate the constraint */
                    else
                        i1++;
                }
                if (isinside)
                    check=0; /* region found ! */
                else {
                    num++;
                    i1=i2+1;             /* get next delimiter i1 */
                    i2+=EXPCON_len[num]; /* get next delimiter i2 */
                }

            }

            if (check==0) {

                for (i=0;i<EXPCON_NU;i++) {
                    u[i]+=EXPCON_G[EXPCON_NU*num+i]; /* previous input plus offset G[num]*/
                    for (j=0;j<EXPCON_NTH;j++)
                        u[i]+=EXPCON_F[EXPCON_NU*num+i+j*EXPCON_NF]*theta[j];
                        //printf("(after) u[%d]=%g\n",i,u[i]);
            }

            iret=num+1; /* current region (reg=1,2,...,EXPCON_REG) */
            }
            else {
                /* VERY BAD! No region was found */

                /* Default values for infeasibility */

                for (i=0;i<EXPCON_NU;i++)
                    #ifdef EXPCON_TRACKING
                        u[i]=u1[i];    /* previous input */
                    #endif
                    #ifdef EXPCON_REGULATION
                        u[i]=0; 
                    #endif
                    iret=-1;
            }
        #endif

        /* Time update of state observer  xk=A*xk+Bu*uk+Bv*vk; */

        for (i=0;i<EXPCON_NX;i++) {
            xaux[i]=0;
        }
        for (i=0;i<EXPCON_NX;i++) {
            for (j=0;j<EXPCON_NX;j++) {
                xaux[i]+=EXPCON_A[i+j*EXPCON_NX]*x[j];
            //printf("xaux[%d]=%g\n",i,xaux[i]);
            }
            for (j=0;j<EXPCON_NU;j++) {
                xaux[i]+=EXPCON_B[i+j*EXPCON_NX]*u[j];
            //printf("xaux[%d]=%g\n",i,xaux[i]);
        }
        }
        for (i=0;i<EXPCON_NX;i++) {
            x[i]=xaux[i];
            //printf("x[%d]=%g\n",i,x[i]);
        }

        #ifdef EXPCON_TRACKING
            /* update u1 */
            for (i=0;i<EXPCON_NU;i++) {
                u1[i]=u[i];
                //printf("u1[%d]=%g\n",i,u1[i]);
            }
        #endif
    }
    return iret;
}
