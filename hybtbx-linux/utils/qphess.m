function hx = qphess(n,nrowh,ncolh,jthcol,hess,x)
%QPHESS Auxiliary routine for the utilization of NAG routines

%(C) 2003 by A. Bemporad, D. Mignone

hx=hess*x;
