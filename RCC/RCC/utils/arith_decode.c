/* MEX ROUTINE FOR ARITHMETIC DECODING */

/*
  Matlab MEX routine for arithmetic coding, modified from the adaptive
  arithmetic coding software by R. M. Neal contained in the following
  reference:
  
    Witten, I. H., Neal, R. M., and Cleary, J. G. (1987) 
      "Arithmetic coding for data compression", Communications 
      of the ACM, vol. 30, no. 6 (June).

  This modified version of the arithmetic coding software allows
  frequencies to be passed for each symbol, rather than estimating them
  adaptively.

  Accepts a Nx1 array of bits, and an NxS array of symbol frequencies.
  Returns an Nx1 output array of symbols ranging from 1..S.
  
  Adapted to MEX format by Phil Sallee  6/19/00
  Modified for steganography embedding by Phil Sallee 6/03
*/


#include <mex.h>
#include "math.h"


/* SIZE OF ARITHMETIC CODE VALUES. */
#define code_value_bits 16		/* Number of bits in a code value   */
#define max_freq 16383
typedef long code_value;		/* Type of an arithmetic code value */
#define top_value (((long)1<<code_value_bits)-1) /* Largest code value */
#define first_qtr ((top_value/4)+1)	       /* Point after first quarter */
#define half	  (2*first_qtr)		       /* Point after first half */
#define third_qtr (3*first_qtr)		       /* Point after third quarter */


/*  [symbols, bitsread, numsym] = decode(in, freqs); */
void mexFunction(int nlhs, mxArray *plhs[],
		 int nrhs, const mxArray *prhs[])
{
  int numsym, numsymval, i, j;
  double *inarr, *symarr, *farr, *p;
  double sum, t, f;
  long cfsum;
  int *outbuf;
  int cum;		/* Cumulative frequency calculated          */
  int symbol;
  long range;
  int maxip;
  int lastbit = 0;
  int ip = 0;           /* input pointer */
  int sd = 0;           /* symbols decoded */
  int br = 0;           /* bits read */
  int btf = 1;          /* bits to follow */
  long *cf;
  
  code_value value;
  code_value low, high;

  /* check arguments */
  if (nrhs != 2) 
    mexErrMsgTxt("Two inputs required");
  else if (nlhs > 3)
    mexErrMsgTxt("Too many output arguments");

  maxip = mxGetM(prhs[0])*mxGetN(prhs[0]);
  if (mxGetM(prhs[0]) != 1 & mxGetN(prhs[0]) != 1)
    mexErrMsgTxt("Input bit array must be a vector");
  
  numsymval = mxGetN(prhs[1]);
  numsym = mxGetM(prhs[1]);

  /* create output array */
  plhs[0] = mxCreateDoubleMatrix(numsym,1,mxREAL);
  
  /* get pointers to arrays */
  symarr = mxGetPr(plhs[0]);
  inarr = mxGetPr(prhs[0]);
  farr = mxGetPr(prhs[1]);

  /* input bits to fill the code value */
  value = 0;
  for (i = 0; i<code_value_bits; i++) {
    value = 2*value;
    if (ip < maxip) {
      if ((inarr[ip] < 0) | (inarr[ip]>1)) mexErrMsgTxt("bad input bit!\n");
      value += (long) inarr[ip++]; 
    }  
  }
    
  /* initialize code range and bits_to_follow */
  low = 0;
  high = top_value;

  /* allocate cumulative frequency array */
  cf = mxMalloc((numsymval+1) * sizeof(long));
  if (cf==NULL) mexErrMsgTxt("Couldn't allocate cumulative freq array");

  /* decode symbols */
  for (i=0; i<numsym; i++) {
    long cfsum;

    /* compute cumulative frequencies */
    sum=0; for (j=0; j<numsymval; j++) sum = sum + farr[i+numsym*j];
    t = (max_freq - numsymval + 1) / sum;
    cfsum = 0;
    for (j=0; j<numsymval; j++) {
      f = ceil(farr[i+numsym*j] * t);
      cf[j] = cfsum;
      cfsum = cfsum + f;
    } 
    cf[j] = cfsum;
    
    /* find cumulative freq for value */
    range = (long)(high-low)+1;
    cum = (((long)(value-low)+1)*cfsum-1)/range;   /* find cum freq for value */
    for (symbol = 1; cf[symbol]<=cum; symbol++) ;    /* then find symbol */

    if (symbol > numsymval) {
      printf("cf[0]=%d, cf[1]=%d, cf[2]=%d, cum=%d\n",cf[0],cf[1],cf[2],cum);
      mexErrMsgTxt("Internal error: bad symbol!\n");
    }

    /* Narrow code range for this symbol */
    high = low + (range*cf[symbol])/cfsum - 1;
    low = low + (range*cf[symbol-1])/cfsum;
    
    if (high < low)
      mexErrMsgTxt("Internal error: bad range!\n");
    
    /* Loop to input bits */
    for (;;) {
      if (high<half) {
        br+=btf; btf=1;
      }
      else if (low>=half) {
	value -= half;
        low -= half;
        high -= half;
        br+=btf; btf=1;
      }
      else if (low>=first_qtr && high<third_qtr) {
	value -= first_qtr;
        low -= first_qtr;
        high -= first_qtr;
        btf++;
      }
      else break;
      low = 2*low;
      high = 2*high+1;

      /* get next input bit */
      value = 2*value;
      if (ip < maxip) {
	if (inarr[ip] < 0 | inarr[ip]>1) mexErrMsgTxt("bad input bit!\n");
	value += inarr[ip++];
      }
      else {
        lastbit = !lastbit;
        value += lastbit;
      }
    }

    symarr[i] = symbol;
    sd++;    

    /* check for too many garbage bits */
    if (br >= maxip) break;
  }

  /* return number of bits read that can be uniquely obtained
     from the symbols that were decoded regardless of any other
     symbols that may follow (necessary for steganographic use) */
  if (nlhs > 1) {
    plhs[1] = mxCreateDoubleMatrix(1,1,mxREAL);
    p = mxGetPr(plhs[1]);
    *p = br;
  }

  /* return number of symbols decoded */
  if (nlhs > 2) {
    plhs[2] = mxCreateDoubleMatrix(1,1,mxREAL);
    p = mxGetPr(plhs[2]);
    *p = sd;
  }

  mxFree(cf);
}
