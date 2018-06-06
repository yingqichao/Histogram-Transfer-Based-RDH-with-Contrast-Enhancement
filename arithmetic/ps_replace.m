function [ps,replace,index]=ps_replace(T)
T=double(T);[r,~]=size(T);
nonz=T>0;
s=(sum(nonz,2))>1;
index=find(s>0);
sumrow=sum(T,2);
ps=[];replace=[];%先确定这两个值
for m=1:length(index)
    n=0;
    for k=1:r
      if T(index(m),k)~=0
          n=n+1;ps(index(m),n)=T(index(m),k)/sumrow(index(m));replace(index(m),n)=k;
      end
    end
end