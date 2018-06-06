function [codebin,codedec]=arithencode(symbol,ps,inseq,nseq)%函数arithencode对symbol进行算术编码
% symbol=['abcd'];
% ps=[0.1 0.4 0.2 0.3];
% inseq=('cadacd');
high_range=[];
for k=1:length(ps)
    high_range=[high_range sum(ps(1:k))];%[0.1 0.5 0.7 1]
end
low_range=[0 high_range(1:length(ps)-1)];%[0 0.1 0.5 0.7]
sbidx=zeros(size(inseq));
for i=1:length(inseq)
    sbidx(i)=find(symbol==inseq(i));%[3 1 4 1 3 4]
end
low=0;high=1;
for i=1:length(inseq)
    range=high-low;
    high=low+range*high_range(sbidx(i));%[0.7]
    low=low+range*low_range(sbidx(i));%[0.5]
end
% acode=low;
acode=(low+high)/2;
codebin=dec2bin_zero(acode,nseq);
codedec=bin2dec_zero(codebin);
if codedec<low
  index=find(codebin==0,1,'last');
  for j=index:length(codebin)
      codebin(j)=~codebin(j);
  end
end
codedec=bin2dec_zero(codebin);
    