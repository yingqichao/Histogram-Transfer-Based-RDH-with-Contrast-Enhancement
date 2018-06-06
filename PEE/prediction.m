function [Hist,Ie,y,seq]=prediction(Img,flag)
%========================================================================
% [Hist,Ie,y,seq]=prediction(Img,flag)
% Input: the cover image, flag =0 represents Set A, otherwise Set B
% Output: Prediction Error Histogram(PEH), image's error
% Output: error map, 4 PEE weights
% Author: William Ying
%----------------------------------------------------------------------
Img=double(Img);
seq=[0.25 0.25 0.25 0.25];%A上，B左，C下，D右
[r,c]=size(Img);
for k=1:100
    SquaredError=0;deri=[0 0 0 0];
    for i=2:r-1
        for j=2:c-1
            if mod((i+j),2)==flag
                e=(seq(1)*Img(i-1,j)+seq(2)*Img(i,j-1)+seq(3)*Img(i+1,j)+seq(4)*Img(i,j+1)-Img(i,j));
                SquaredError=SquaredError+e^2;
                deri(1)=deri(1)+2*e*Img(i-1,j);
                deri(2)=deri(2)+2*e*Img(i,j-1);
                deri(3)=deri(3)+2*e*Img(i+1,j);
                deri(4)=deri(4)+2*e*Img(i,j+1);
            end
        end
    end
    if k==1
       OriSqrErr=SquaredError;
    end
    idx=find(abs(deri)==max(abs(deri)));
    if SquaredError<=OriSqrErr/4
        break;
    end
    fraction=0.05*(1-(k/100));
    if deri(idx)>0;
        seq(idx)=seq(idx)-fraction;
    else
        seq(idx)=seq(idx)+fraction;
    end
    disp(['SquaredError:' num2str(SquaredError)]);
end
%用8位2进制量化4个值
for i=1:4
    bin=dec2bin_zero(seq(i),8);
    seq(i)=bin2dec_zero(bin);
end

Ie=zeros(size(Img));
for i=2:r-1
        for j=2:c-1
            if mod((i+j),2)==flag
                Ie(i,j)=round((seq(1)*Img(i-1,j)+seq(2)*Img(i,j-1)+seq(3)*Img(i+1,j)+seq(4)*Img(i,j+1)-Img(i,j)));
            end
        end
end
emin=min(min(Ie));emax=max(max(Ie));y=emin:emax;
Hist=zeros(emax-emin+1,1);
for i=2:r-1
        for j=2:c-1
            if mod((i+j),2)==flag
                idx=Ie(i,j)-emin+1;
                Hist(idx)=Hist(idx)+1;
            end
        end
end
thresh=round(r*c/4096);i=1;
while i<=length(Hist)
    if Hist(i)<thresh
        Hist(i)=[];y(i)=[];
    else
        i=i+1;
    end
end
Hist=round(Hist*2048/(r*c));
end





