function [seq_rest,BW,casted]=runlengthdecoding(seq,row,col,bits)
BW=zeros(row,col);N=row*col;runned=0;casted=0;
while(runned<N)
    value=0;
    while(bin2dec(char(seq(1:bits)+48))==2^bits-1)
       value=value+31; 
       if runned+value>N
           break;
       else
       seq(1:bits)=[];casted=casted+bits;
       end
    end
    value=value+bin2dec(char(seq(1:bits)+48));
    if runned+value>N
        break;
    else
        runned=runned+1+value;
        BW(runned)=1;
        seq(1:bits)=[];casted=casted+bits;
    end
end
BW=BW';seq_rest=seq;

