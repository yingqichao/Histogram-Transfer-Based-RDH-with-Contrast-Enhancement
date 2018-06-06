function [V,H,D,A]=IWT(I)
[row,col]=size(I);
V=zeros(row/2,col/2);H=zeros(row/2,col/2);D=zeros(row/2,col/2);A=zeros(row/2,col/2);
for p=1:row/2
    for q=1:col/2
        A(p,q)=floor((floor((I(2*p-1,2*q-1)+I(2*p-1,2*q))/2)+floor((I(2*p,2*q-1)+I(2*p,2*q))/2))/2);
        V(p,q)=floor((I(2*p-1,2*q)-I(2*p-1,2*q-1)+I(2*p,2*q)-I(2*p,2*q-1))/2);
        H(p,q)=floor((I(2*p,2*q-1)+I(2*p,2*q))/2)-floor((I(2*p-1,2*q-1)+I(2*p-1,2*q))/2);
        D(p,q)=I(2*p,2*q)-I(2*p,2*q-1)-I(2*p-1,2*q)+I(2*p-1,2*q-1);
    end
end

% [A,H,V,D]=dwt2(I,'bior3.7');