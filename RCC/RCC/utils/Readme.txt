1, firstly goto the utils directory, run following commands inside Matlab (you need a c++ compiler installed):
		mex arith_encode.c
		mex arith_decode.c
2, Back to the RCC directory, and run testEmbed.m, after few seconds you'll see the results~


I tested it using Matlab R2012b.


*************************************
the utils directory offers functions to do optimization problem and recursively embedding messages.