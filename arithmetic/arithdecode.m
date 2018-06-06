function outseq=arithdecode(symbol,ps,codedec,SYMLEN)
%函数arithdecode对算术进行解码
format long e;
high_range=[];
for k=1:length(ps)
    high_range=[high_range sum(ps(1:k))];
end
low_range=[0 high_range(1:length(ps)-1)];
psmin=min(ps);
outseq=[];
for i=1:SYMLEN
    idx=max(find(low_range<=codedec));
    codedec=codedec-low_range(idx);
%     if abs(codedec-ps(idx))<0.01*psmin
%         idx=idx+1;
%         codedec=0;
%     end
    outseq=[outseq symbol(idx)];
    codedec=codedec/ps(idx);
    if abs(codedec)<0.01*psmin
        i=SYMLEN+1;
    end
end