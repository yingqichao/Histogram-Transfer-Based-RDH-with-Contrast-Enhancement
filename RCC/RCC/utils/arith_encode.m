% [BITS] = ARITH_ENCODE(SYMBOLS,FREQS)
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
% Accepts a Nx1 array of symbols 1..S, and an NxS array of
% symbol frequencies.  Returns an Nx1 output array of bits.
%
% This routine has been modified to return only the bits which are uniquely
% described by the given symbols, which is only desirable if the routine
% is used for steganography purposes in which the symbols are transmitted
% to represent the bits instead of the other way around.  Normally, extra
% bits are added to ensure that the symbols are unambiguously described.
  
% Adapted to MEX format by Phil Sallee  6/19/00
% Modified for steganography decoding by Phil Sallee  6/03

error('Need to compile MEX routine ARITH_ENCODE.C  Type "mex arith_encode.c".');
