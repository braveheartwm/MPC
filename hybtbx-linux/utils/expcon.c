/* Explicit controller - State feedback

reg=control(double *u, double *theta)

Compute the optimal control action u given the parameter vector th(t).
For linear regulators, th(t)=x(t) is the current state. 
For hybrid regulators, th(t)=[x(t);r(t)] also contains the reference signals.

The output argument reg is the region number.

(C) 2003-2004 by A. Bemporad and A. Alessio
*/

#include "expcon.h"
#include <stdio.h> 

#ifdef EXPCON_HYB2NORM
	#include <float.h>   /* needed to define largest double DBL_MAX */
	
    /* If calloc is used instead of static variables:
	#include <malloc.h>  /* for allocating memory for auxiliary vectors with calloc  */

#endif

static int expcon(double *u, double *th)

{
	int i,j,k;
	int iret;
	int i1,i2,num,check,isinside;
	double aux;
	int infeasible=1;
	int found;

#ifdef EXPCON_UNCONSTRAINED
	/* Unconstrained control */
	for (i=0;i<EXPCON_NU;i++) {
		u[i]=0;
		for (j=0;j<EXPCON_NTH;j++)
			u[i]+=EXPCON_F[i+j*EXPCON_NU]*th[j];
		/* printf("u[%d]=%g\n",i,u[i]); */
	}
	iret=0;
#endif

#ifdef EXPCON_CONSTRAINED

	/* Constrained explicit control */

	#ifndef EXPCON_HYB2NORM
    
	    /* Linear search in polyhedral partition */
	
	i1=0;                /* H(i1:i2,:), K(i1:i2) = current region */
	i2=EXPCON_len[0]-1;
	num=0;
	check=1;

	while ((num<EXPCON_REG) && check) {
		isinside=1;
		while ((i1<=i2) && isinside) {
			aux=0;
			for (j=0;j<EXPCON_NTH;j++)
				aux+=(double)EXPCON_H[i1+j*EXPCON_NH]*th[j];
			if (aux>(double)EXPCON_K[i1])
				isinside=0; /* get out of the loop, th violates the constraint */
			else
				i1++;
		}
		if (isinside) {
			check=0; /* region found ! */
			infeasible=0;
		}
		else {
			num++;
			i1=i2+1;             /* get next delimiter i1 */
			i2+=EXPCON_len[num]; /* get next delimiter i2 */
		}

	}

	if (check==0) {

		for (i=0;i<EXPCON_NU;i++) {
			u[i]=EXPCON_G[EXPCON_NU*num+i]; /* add offset G[num]*/
			for (j=0;j<EXPCON_NTH;j++)
				u[i]+=EXPCON_F[EXPCON_NU*num+i+j*EXPCON_NF]*th[j];
		}

		iret=num+1; /* current region (reg=1,2,...,EXPCON_REG) */
	}
	// Otherwise, infeasible=1

	#else

	/* Linear search in overlapping polyhedral partitions */
	
	double valuestar=DBL_MAX;
	
	/* If calloc is used instead of static variables:

	double *thisUseq; // stores optimal sequence uc(0),uc(1),...,uc(T-1),slack
	double *thisUb;  // stores optimal ub(0)
	double *thaux;
	double *xaux;
	
	*/

	static double thisUseq[EXPCON_NVAR]; /* optimal sequence uc(0),uc(1),...,uc(T-1),slack */
	static double thisUb[EXPCON_NUB+1];  /* optimal ub(0) */
	static double thaux[EXPCON_NTH];     /* aux. parameter vector */
	static double xaux[EXPCON_NVAR];     /* aux. optimal sequence vector */

	double cost;
	int jj,ii,jj2,hh,offset;
	int regionstar;

	/* printf("th=[");
	for(jj=0;jj<EXPCON_NTH;jj++)
		printf("%5.2f ",th[jj]);
	printf("]';\n"); */
		
	regionstar=0;
	num=0;
	k=0; // absolute index of current region in the cumulated partition 
	
	
	/* If calloc is used instead of static variables:

	thisUseq=(double*)calloc(EXPCON_NVAR,sizeof(double));
	if (EXPCON_NUB>0)
		thisUb=(double*)calloc(EXPCON_NUB,sizeof(double));
	
	thaux=(double*)calloc(EXPCON_NTH,sizeof(double));	
	xaux=(double*)calloc(EXPCON_NVAR,sizeof(double));
	
	*/

	for(j=0;j<EXPCON_NPART;j++) /* cycle on all partitions (scalar) */
	{
		offset=EXPCON_offset[j];

		i=0;	
		found=1;
		k=0;
		i1=0;
		
		for(jj=0;jj<j;jj++) k+=EXPCON_NR[jj];
			i2=EXPCON_len[k]-1;

		while((i<EXPCON_NR[j])&&(found)) /* cycle on each region of the partition (vector) */
		{	

			check=1;
			isinside=1;
			while ((i1<=i2) && isinside) 
			{	
				aux=0;
				for (jj2=0;jj2<EXPCON_NTH;jj2++)
					aux+=(double)EXPCON_H[offset+jj2*EXPCON_NH+i1]*th[jj2];
				if (aux>(double)EXPCON_K[offset+i1])
					isinside=0; /* get out of the loop, th violates the constraint */
				else
					i1++;
			}
			if(isinside)
			{

				// calculate thisUseq=(uc[0]..uc[T-1] slack) or (uc[0]..uc[T-1] slack)
				ii=-1;
				for(hh=0;hh<EXPCON_NGAIN;hh++)
				{
					if ((hh<EXPCON_NUC) || (hh>=EXPCON_NUC+EXPCON_NUB))
					{
						ii++;
						thisUseq[ii]=EXPCON_G[EXPCON_NGAIN*(k+i)+hh];
		
						for(jj=0;jj<EXPCON_NTH;jj++)
							thisUseq[ii]+=EXPCON_F[EXPCON_NGAIN*(k+i)+hh+jj*EXPCON_NF]*th[jj];
					}
					else
						// ub(0) does not depend on F, only on G
						thisUb[hh-EXPCON_NUC]=EXPCON_G[EXPCON_NGAIN*(k+i)+hh];
				}
				// calculate cost

				cost=EXPCON_d[j];// constant term

				for(ii=0;ii<EXPCON_NVAR;ii++)
					cost+=EXPCON_C[ii+j*EXPCON_NVAR]*thisUseq[ii];

				for(ii=0;ii<EXPCON_NTH;ii++)
					cost+=EXPCON_V[ii+j*EXPCON_NTH]*th[ii];

				// Clean up aux vector
				for(ii=0;ii<EXPCON_NTH;ii++)
					thaux[ii]=0;

				for(ii=0;ii<EXPCON_NTH;ii++)
					for(jj=0;jj<EXPCON_NTH;jj++)
						thaux[ii]+=EXPCON_Y[jj*(EXPCON_NTH*EXPCON_NPART)+ii+j*EXPCON_NTH]*th[jj];

				for(ii=0;ii<EXPCON_NTH;ii++)
					cost+=.5*thaux[ii]*th[ii];
						
				// Clean up aux vector
				for(ii=0;ii<EXPCON_NVAR;ii++)
					xaux[ii]=0;

				for(ii=0;ii<EXPCON_NVAR;ii++)
					for(jj=0;jj<EXPCON_NTH;jj++)
						xaux[ii]+=EXPCON_D[jj*(EXPCON_NVAR*EXPCON_NPART)+ii+j*EXPCON_NVAR]*th[jj];

				for(ii=0;ii<EXPCON_NVAR;ii++)
					cost+=xaux[ii]*thisUseq[ii];

				// Clean up aux vector
				for(ii=0;ii<EXPCON_NVAR;ii++)
					xaux[ii]=0;

				for(ii=0;ii<EXPCON_NVAR;ii++)
					for(jj=0;jj<EXPCON_NVAR;jj++)
						xaux[ii]+=EXPCON_H1[jj*(EXPCON_NVAR*EXPCON_NPART)+ii+j*EXPCON_NVAR]*thisUseq[jj];

				for(ii=0;ii<EXPCON_NVAR;ii++)
					cost+=.5*xaux[ii]*thisUseq[ii];

				if (cost < valuestar) 
				{
					valuestar=cost;
					for(ii=0;ii<EXPCON_NUC;ii++)
						u[ii]=thisUseq[ii];

					for(ii=0;ii<EXPCON_NUB;ii++)
						u[ii+EXPCON_NUC]=thisUb[ii];

					num=k+i;
					regionstar=num;
				}
				found=0;
				check=0;
				infeasible=0;
			}
			i++;
			i1=i2+1;
			i2+=EXPCON_len[k+i];
		}
	}

	iret=regionstar+1;

	/* If calloc is used instead of static variables:
	
	free(thaux);
	free(xaux);
	free(thisUseq);

	if (EXPCON_NUB>0)
		free(thisUb);

	*/

	#endif

	if (infeasible == 1) 
	{
		/* VERY BAD! No region was found */

		/* Default values for infeasibility */

		#ifdef EXPCON_REGULATION
		for (i=0;i<EXPCON_NU;i++)
			u[i]=0; 
		#endif
		iret=-1;

        printf("Parameter vector outside partition\n");
	}

#endif

	return iret;
}
