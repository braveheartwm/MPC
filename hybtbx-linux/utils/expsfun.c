/* expsfun.c: Evaluation of explicit PWA controllers for linear systems 
Simulink/RTW S-Function

(C) 2003 by A. Bemporad      */

/* Standard prologue */

#define S_FUNCTION_NAME  expsfun
#define S_FUNCTION_LEVEL 2

/* #define MATLAB_MEX_FILE 1    removed on Dec 4, 2007 to be able to compile with RTW */

#include <stdlib.h>
#include <math.h>
//#include <malloc.h>
#include "simstruc.h"
#include "expsfun.h"


/* Parameter error message */
#define param_MSG "Parameter number mismatch"


/* S-Function callback methods */

static void mdlCheckParameters(SimStruct *S)

{
}

/* #define DEBUG */

static void mdlInitializeSizes (SimStruct *S)   /*Init sizes array */
{
	/* No continuous states */

	ssSetNumContStates(S, 0);


	/* No discrete states, work vectors will do - except open loop */
	ssSetNumDiscStates(S, 0);  /* don't duplicate workvalues to states when using RTW */

	/* Set up input ports */
	if (!ssSetNumInputPorts(S, 1))
		return;

	ssSetInputPortVectorDimension(S,0,EXPCONSFUN_NINPUTS); /* the +1 is for the fake reference */

	/* Set up output ports */
	if (!ssSetNumOutputPorts(S,1)) /* one output port */
		return;

	ssSetOutputPortVectorDimension(S, 0,EXPCONSFUN_NU+1); /* input + region number */

	ssSetInputPortDirectFeedThrough(S,0,1); /* direct feedthrough from y/x,r to u,reg */

	/* One sample time */

	ssSetNumSampleTimes(S, 1);

	ssSetOptions(S,SS_OPTION_EXCEPTION_FREE_CODE);

	//printf("mdlInitializeSizes DONE!\n");
}

static void mdlInitializeSampleTimes(SimStruct *S)
{	
	ssSetSampleTime(S, 0, EXPCONSFUN_TS);
	ssSetOffsetTime(S, 0, 0.0);

	//printf("mdlInitializeSampleTimes DONE!\n");
}


#define MDL_INITIALIZE_CONDITIONS

static void mdlInitializeConditions(SimStruct *S)

{

#ifdef EXPCONSFUN_OBSERVER

	//double *u;
	static double u[EXPCONSFUN_NU];

	double dummy1, dummy2;
	int init;

	//u = calloc(EXPCONSFUN_NU,sizeof(double));

	init=1;
	//printf("mdlInitializeConditions START!\n");

	expconobs(u,&dummy1,&dummy2,init); /* lastu gets initialized, as well as internal vars */
	//printf("u assigned: u[0]=%g\n",u[0]);

	//printf("mdlInitializeConditions DONE!\n");
	//free(u);

#endif
}

static void mdlOutputs(SimStruct *S, int_T tid) 
{

	static int_T nym, ny;

	int reg;        /* Region number */ 
	int i,j;
	int init=0;
    int nyref,nxref; /* number of y/x references, including dummy due to empty signal to block
    
	//double *u;
	//real_T *r;    /* Reference signals */
	//real_T *ym;    /* Vector of measurements (either x or ym) */

	static double u[EXPCONSFUN_NU];
	static real_T r[EXPCONSFUN_NREFS+1]; /* Reference signals */
	static real_T ym[EXPCONSFUN_NYM];    /* Vector of measurements (either x or ym) */

#ifdef EXPCON_HYBRID_MODEL
	//double *theta;
	//real_T *rx;
	//real_T *ru;
	//real_T *ry;
    static double theta[EXPCON_NTH];
	static real_T rx[EXPCONSFUN_NRX+1];
	static real_T ru[EXPCONSFUN_NRU+1];
	static real_T ry[EXPCONSFUN_NRY+1];
#else
	//double *rr;
	//double *yym;
	static double rr[EXPCONSFUN_NREFS+1];
	static double yym[EXPCONSFUN_NYM];
#endif

	InputRealPtrsType uPtrs;
	real_T *u_out;

	/* Work vectors */
	//u = calloc(EXPCONSFUN_NU,sizeof(double));
	//r = calloc(EXPCONSFUN_NREFS,sizeof(real_T));
	//ym = calloc(EXPCONSFUN_NYM,sizeof(real_T));
#ifdef EXPCON_HYBRID_MODEL
	//theta=calloc(EXPCON_NTH,sizeof(double));
	//rx = calloc(EXPCONSFUN_NRX,sizeof(real_T));
	//ru = calloc(EXPCONSFUN_NRU,sizeof(real_T));
	//ry = calloc(EXPCONSFUN_NRY,sizeof(real_T));
#else
	//rr = calloc(EXPCONSFUN_NREFS,sizeof(double));
	//yym = calloc(EXPCONSFUN_NYM,sizeof(double));
#endif

	/* Retrieve pointers to input and output vectors */

	uPtrs = ssGetInputPortRealSignalPtrs(S,0); /* only (S,0), as there's only one input port ... */
	u_out = ssGetOutputPortRealSignal(S,0);    /* only (S,0), as there's only one output port ...*/     

	/* Get measurements from input port */
	for (i=0; i<EXPCONSFUN_NYM; i++) {
		ym[i]=*uPtrs[i];
	}

#ifdef EXPCON_HYBRID_MODEL
	i=-1;
    if (EXPCONSFUN_NRY>=EXPCONSFUN_NO_REF)
        nyref=EXPCONSFUN_NRY;
    else
        nyref=EXPCONSFUN_NO_REF;
    if (EXPCONSFUN_NRX>=EXPCONSFUN_NO_REFX)
        nxref=EXPCONSFUN_NRX;
    else
        nxref=EXPCONSFUN_NO_REFX;
    
    for (j=0; j<EXPCONSFUN_NREFS+EXPCONSFUN_NO_REF+EXPCONSFUN_NO_REFX; j++) {
        if (EXPCONSFUN_NRY>0 && j<nyref) {
            i=i+1;
            if (j<EXPCONSFUN_NRY) {
                if (EXPCONSFUN_NO_REF)
                    r[i]=0;
                else
                    r[i] = *uPtrs[j+EXPCONSFUN_NYM]; /* grab signal from input port */
            }
        }
        
        if (EXPCONSFUN_NRX>0 && j>=nyref && j<nyref+nxref){
            i=i+1;
            if (j<EXPCONSFUN_NRX+nyref) {
                if (EXPCONSFUN_NO_REFX)
                    r[i]=0;
                else
                    r[i] = *uPtrs[j+EXPCONSFUN_NYM]; /* grab signal from input port */
            }
        }
        
        if (EXPCONSFUN_NRU>0 && j>=nyref+nxref) {
            i=i+1;
            if (j<EXPCONSFUN_NRU+nyref+nxref) {
                if (EXPCONSFUN_NO_REFU)
                    r[i]=0;
                else
                    r[i] = *uPtrs[j+EXPCONSFUN_NYM]; /* grab signal from input port */
            }
        }
    }
	
	/* Scramble order of reference on x,y,u: EXPCON wants [xc,xrc,urc,yrc] */
	for (j=0; j<EXPCONSFUN_NRY; j++)
		ry[j]=r[j];
	for (j=0; j<EXPCONSFUN_NRX; j++)
		rx[j]=r[j+EXPCONSFUN_NRY];
	for (j=0; j<EXPCONSFUN_NRU; j++)
		ru[j]=r[j+EXPCONSFUN_NRY+EXPCONSFUN_NRX];
	
	j=0;
	for (i=0; i<EXPCONSFUN_NRX; i++) {
			r[j]=rx[i];
			j=j+1;
	}
	for (i=0; i<EXPCONSFUN_NRU; i++) {
			r[j]=ru[i];
			j=j+1;
	}
	for (i=0; i<EXPCONSFUN_NRY; i++) {
			r[j]=ry[i];
			j=j+1;
	}

#else
	for (j=0; j<EXPCONSFUN_NREFS; j++) {
		if (EXPCONSFUN_NO_REF)
			r[j] = 0;  /* default: r=0 */
		else 
			r[j] = *uPtrs[j+EXPCONSFUN_NYM];
	}
#endif


	/* EXECUTE EXPCONOBS.C  or EXPCON.C */

#ifdef EXPCON_HYBRID_MODEL
	for (i=0; i<EXPCONSFUN_NYM; i++) {
		theta[i]=(double) ym[i];
	}
	for (i=0; i<EXPCONSFUN_NREFS; i++) {
		theta[EXPCONSFUN_NYM+i]=(double) r[i];
	}

#else
	for (i=0; i<EXPCONSFUN_NYM; i++) {
		yym[i]=(double) ym[i];
	}
	for (i=0; i<EXPCONSFUN_NREFS; i++) {
		rr[i]=(double) r[i];
	}
	//printf("(Before) u=%g, yym=%g, rr=%g\n",u[0],yym[0],rr[0]);
#endif

#ifdef EXPCONSFUN_OBSERVER
	reg=expconobs(u,yym,rr,init);
#endif

#ifdef EXPCON_REGULATION
	reg=expcon(u,yym);
#endif

#ifdef EXPCON_HYBRID_MODEL
	reg=expcon(u,theta);
#endif

	//printf("(After) u=%g, yym=%g, rr=%g\n",u[0],yym[0],rr[0]);

	for (i=0; i<EXPCONSFUN_NU; i++){
		u_out[i] = (real_T)u[i]; 
	}    
	u_out[EXPCONSFUN_NU] = (real_T)reg; 

	//free(u);
	//free(r);
	//free(ym);
#ifdef EXPCON_HYBRID_MODEL
	//free(theta);
	//free(rx);
	//free(ru);
	//free(ry);

#else
	//free(rr);
	//free(yym);
#endif
}

#define MDL_UPDATE

static void mdlUpdate(SimStruct *S, int_T tid)
{
}


static void mdlTerminate(SimStruct *S)
{
}

#ifdef  MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif
