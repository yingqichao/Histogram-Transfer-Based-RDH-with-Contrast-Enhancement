function SYMLEN=allocate(len)
slen=ceil(len/10);smod=mod((slen*10-len),10);
SYMLEN=[];
SYMLEN(1:slen)=10;
k=1;
for i=1:smod
    SYMLEN(k)=SYMLEN(k)-1;
    k=k+1;
    if k>slen
        k=1;
    end
end