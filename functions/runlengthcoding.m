function [RLC]=runlengthcoding(BW,bits)
[r,c]=size(BW);RLC=[];zero=0;
for i=1:r
    for j=1:c
        if abs(BW(i,j))==1
            RLC=[RLC dec2bin(zero,bits)-48];
            zero=0;
        else
            if zero==2^bits-1%(5bits)
                zero=0;RLC=[RLC 1 1 1 1 1];
            else
                zero=zero+1;
            end
        end
    end
end