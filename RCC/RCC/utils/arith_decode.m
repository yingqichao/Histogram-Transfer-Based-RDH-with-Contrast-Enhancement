% [SYMBOLS, BITSREAD, NUMSYM] = ARITH_DECODE(BITS, FREQS)
% 
% Matlab MEX routine for arithmetic coding, modified from the adaptive
% arithmetic coding software by R. M. Neal contained in the following
% reference:
%   
%   Witten, I. H., Neal, R. M., and Cleary, J. G. (1987) 
%     "Arithmetic coding for data compression", Communications 
%     of the ACM, vol. 30, no. 6 (June).
%
% This modified version of the arithmetic coding software allows
% frequencies to be passed for each symbol, rather than estimating them
% adaptively.
%
% Accepts a Nx1 array of bits, and an NxS array of symbol frequencies.
% Returns an Nx1 output array of symbols ranging from 1..S.
%
% This routine has been modified to return the number of bits read 
% that can be uniquely determined from the decoded symbols (BITSREAD) as
% well as the number of symbols used (NUMSYM).  This is necessary for 
% steganography purposes in which the symbols are used as a transmission
% channel to send a message which may have arbitrary length.
  
% Adapted to MEX format by Phil Sallee  6/19/00
% Modified for steganography embedding by Phil Sallee  6/03

error('Need to compile MEX routine ARITH_DECODE.C  Type "mex arith_decode.c".');
