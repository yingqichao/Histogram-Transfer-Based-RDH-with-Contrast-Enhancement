function dec=bin2dec_zero(bin)
%========================================================================
% dec=bin2dec_zero(bin)
% Input: a binary sequence that only contains 0 or 1
% Output: the relevant decimal number
% Author: William Ying
%----------------------------------------------------------------------
dec=0;
for i=1:length(bin)
    if bin(i)==1
     dec=dec+2^(-i);
    end
end