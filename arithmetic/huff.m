%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Huffman Tree
%%% Input: M*N sequence containing transfer possibility ranging from 0 to 1
%%% Output:M*N cells containing huffman codes
%%% by William Ying 2017.9
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function core=huff(pseq)
% pseq=[0.4 0.1 0.2 0.3];%[1,001,000,01]
core=cell(length(pseq),1);index=1:1:length(pseq);p=pseq;
for i=1:length(pseq)-1
    m=find(p==min(p));z=[];
    for j=1:length(m)
        z(j)=length(find(index==m(j)));
    end
    m=m(find(z==min(z),1,'first'));
%         if core{find(index==m)}=={[]}
%             core{find(index==m)}='1';
%         else
%             core{find(index==m)}=['1',core(find(index==m))];
%         end
    change=find(index==m);
    for aa=1:length(change)
        core{change(aa)}=strcat('1',core{change(aa)});
    end
    MIN=min(p);p(m)=1;
    n=find(p==min(p));z=[];
    for j=1:length(n)
        z(j)=length(find(index==n(j)));
    end
    n=n(find(z==min(z),1,'first'));

%         if core{find(index==n)}=={[]}
%             core{find(index==n)}='0';
%         else
%             core{find(index==n)}=['0',core(find(index==n))];
%         end
    change=find(index==n);
    for aa=1:length(change)
        core{change(aa)}=strcat('0',core{change(aa)});
    end
    p(n)=MIN+min(p);index(find(index==m))=n;
    
end