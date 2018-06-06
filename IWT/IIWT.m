function [I]=IIWT(V,H,D,A)
[row,col]=size(V);
I=zeros(2*row,2*col);
for p=1:row
    for q=1:col
        I(2*p-1,2*q-1)=A(p,q)-floor(H(p,q)/2)-floor((V(p,q)-floor(D(p,q)/2))/2);
        I(2*p,2*q-1)=A(p,q)+floor((H(p,q)+1)/2)-floor((V(p,q)+floor((D(p,q)+1)/2))/2);
        I(2*p-1,2*q)=A(p,q)-floor(H(p,q)/2)+floor((V(p,q)-floor(D(p,q)/2)+1)/2);
        I(2*p,2*q)=A(p,q)+floor((H(p,q)+1)/2)+floor((V(p,q)+floor((D(p,q)+1)/2)+1)/2);
    end
end