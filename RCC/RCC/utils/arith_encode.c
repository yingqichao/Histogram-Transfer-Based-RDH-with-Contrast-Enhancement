/* MEX ROUTINE FOR ARITHMETIC ENCODING */

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

  Accepts a Nx1 array of symbols 1..S, and an NxS array of
  symbol frequencies.  Returns an Nx1 output array of bits.
  
  Adapted to MEX format by Phil Sallee  6/19/00
  Modified for steganography decoding by Phil Sallee 6/03
*/


#include <mex.h>
#include "math.h"


/* SIZE OF ARITHMETIC CODE VALUES. */
#define code_value_bits 16	    /* Number of bits in a code value   */
#define max_freq 16383
typedef long code_value;	   /* Type of an arithmetic code value */
#define top_value (((long)1<<code_value_bits)-1) /* Largest code value */
#define first_qtr ((top_value/4)+1)	       /* Point after first quarter */
#define half	  (2*first_qtr)		       /* Point after first half */
#define third_qtr (3*first_qtr)		       /* Point after third quarter */


/*  [out] = encode(symbols,freqs); */
void mexFunction(int nlhs, mxArray *plhs[],
		 int nrhs, const mxArray *prhs[])
{
  int numsym, numsymval, i, j;
  double *outarr, *symarr, *farr;
  double sum, t, f;
  int *outbuf, *tmpptr;
  int symbol;
  long range;
  int op = 0;           /* output pointer */
  int maxop;
  long *cf;

  code_value low, high;	/* Ends of the current code region          */
  long bits_to_follow;	/* Number of opposite bits to output after  */
			/* the next bit.                            */

  /* check arguments */
  if (nrhs != 2) 
    mexErrMsgTxt("Two inputs required");
  else if (nlhs > 1)
    mexErrMsgTxt("Too many output arguments");

  if (mxGetN(prhs[0]) != 1)
    mexErrMsgTxt("Input symbol array must be a column vector");
  
  numsymval = mxGetN(prhs[1]);
  numsym = mxGetM(prhs[0]);
  
  if (mxGetM(prhs[1]) != numsym)
    mexErrMsgTxt("Frequency array must have same num of rows as symbol array");
  
  /* allocate extra large buffer to hold output */
  maxop = numsym * numsymval + 100;
  outbuf = mxCalloc(maxop, sizeof(int));

  /* get pointers to arrays */
  symarr = mxGetPr(prhs[0]);
  farr = mxGetPr(prhs[1]);

  /* allocate cumulative frequency array */
  cf = mxMalloc((numsymval+1) * sizeof(long));
  if (cf==NULL) mexErrMsgTxt("Couldn't allocate cumulative freq array");

  /* start encoding, initialize code range and bits_to_follow */
  low = 0;
  high = top_value;
  bits_to_follow = 0;
  
  /* encode symbols */
  for (i=0; i<numsym; i++) {
    long cfsum;

    /* compute cumulative frequencies */
    sum=0; for (j=0; j<numsymval; j++) sum = sum + farr[i+numsym*j];
    if (sum==0) mexErrMsgTxt("All symbol frequencies are 0\n");
    t = (max_freq - numsymval + 1) / sum;
    cfsum = 0;
    for (j=0; j<numsymval; j++) {
      f = ceil(farr[i+numsym*j] * t);
      cf[j] = cfsum;
      cfsum = cfsum + (int) f;
    } 
    cf[j] = cfsum;
    if (cfsum==0) mexErrMsgTxt("All symbol frequencies are 0\n");
    
    /* get next symbol to encode */
    symbol = (int) symarr[i];
    if ((symbol < 1) | (symbol > numsymval))
      mexErrMsgTxt("Symbol out of range\n");
    
    if (cf[symbol-1] == cf[symbol])
      mexErrMsgTxt("Can't encode symbol with zero frequency\n");

    /* Narrow code range for this symbol */
    range = (long)(high-low)+1;
    high = low + (range*cf[symbol])/cfsum - 1;
    low = low + (range*cf[symbol-1])/cfsum;
    
    /* Loop to output bits */
    for (;;) {
      
      if (op + bits_to_follow > maxop - 4) {
	maxop = maxop * 2;
        printf("reallocating memory for %d ints\n",maxop);
	tmpptr = mxRealloc(outbuf, maxop * sizeof(int));
        if (tmpptr == NULL) mexErrMsgTxt("Can't reallocate memory");
        else outbuf = tmpptr;
      }
      
      if (high<half) {		                /* Output 0 if in low half. */
	outbuf[op++] = 0;	
        while (bits_to_follow > 0) {
          outbuf[op++] = 1;
	  bits_to_follow -= 1;
	}
      } 
      else if (low>=half) {			/* Output 1 if in high half.*/
	outbuf[op++] = 1;	
        while (bits_to_follow > 0) {
          outbuf[op++] = 0;
	  bits_to_follow -= 1;
	}
        low -= half;
        high -= half;			        /* Subtract offset to top.  */
      }
      else if (low>=first_qtr			/* Output an opposite bit   */
            && high<third_qtr) {		/* later if in middle half. */
        bits_to_follow += 1;
        low -= first_qtr;			/* Subtract offset to middle*/
        high -= first_qtr;
      }
      else break;				/* Otherwise exit loop.     */
      low = 2*low;
      high = 2*high+1;			        /* Scale up code range.     */
    }
  }


  /* Normally, we would now output two bits to select the current quarter
   * of the code range.  This ensures that the encoded bits can
   * be decoded unambiguously to return the symbols read.  However, for 
   * steganographic purposes, we want to make sure we only return the 
   * bits that are unabiguously encoded by the symbols.  So we return only
   * the bits we have read so far and comment out this section.
  bits_to_follow += 1;
  if (low<first_qtr) {
    outbuf[op++] = 0;	
    while (bits_to_follow > 0) {
      outbuf[op++] = 1;
      bits_to_follow -= 1;
    }
  }
  else {
    outbuf[op++] = 1;	
    while (bits_to_follow > 0) {
      outbuf[op++] = 0;
      bits_to_follow -= 1;
    }
  }
  */

  /* create new output array of correct size and fill it */
  plhs[0] = mxCreateDoubleMatrix(op,1,mxREAL);
  outarr = mxGetPr(plhs[0]);
  for (i=0; i<op; i++) outarr[i] = outbuf[i];

  /* free temporary output buffer */
  mxFree(outbuf);
  mxFree(cf);
}
