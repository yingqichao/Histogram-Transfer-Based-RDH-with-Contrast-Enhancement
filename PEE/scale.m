function [H,Weight,e_vector,X]=scale(Img,Sign)
%¡ª¡ªImg:matrix,Sign:0 for set A,1 for set B
[row,col]=size(Img);
%find weights
up=0.41;down=0.4;left=0.09;right=0.1;

%original error
N=ceil((row-2)*(col-2)/2);Thresh=floor(N/4096);
e_vector=nan(1,N);num=1;
for i=2:row-1
    for j=2:col-1
        if mod(i+j,2)==Sign;
            e_vector(num)=round(Img(i,j)-left*Img(i,j-1)-right*Img(i,j+1)-up*Img(i-1,j)-down*Img(i+1,j));
            num=num+1;
        end
    end
end
X=-floor(N/2):1:ceil(N/2);
G=hist(e_vector,X);
Glen=length(G);Nlow=0;Nhigh=0;
for i=1:Glen
    if X(i)>=0
        break;
    elseif G(i)<=Thresh
        Nlow=i;
    end
end
for i=Glen:-1:1
    if X(i)<=0
        break;
    elseif G(i)<=Thresh
        Nhigh=i;
    end
end
H=G(Nlow+1:Nhigh-1);X=X(Nlow+1:Nhigh-1);Hlen=length(H);
for i=1:Hlen
   H(i)=round(H(i)*2048/N); 
end

Weight=[left,right,up,down];



