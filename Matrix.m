%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%this version only consider allocating empty bins near 50 peaks.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [T,rate,mssim,mpcqi,X]=Matrix(iterate,Trans,wtbar,dec,I,ImgRev,row,col)
T=Trans;
if wtbar==1
    h=waitbar(0,'Attend,s''il vous plait!');
end
count=1;

for IterationNum=1:iterate
    Maxi=0;Maxj=0;Maxk=0;Maxlambda=0;
    TSumCol=sum(T);TSumRow=sum(T,2);
    for i=1:256
        if TSumRow(i)==0
            continue;
        else
        for j=1:256
            if T(i,j)>1
                for k=max(1,j-2):min(256,j+2)
                    if k~=j && (TSumCol(j)>TSumCol(k))
                        lambda=log2(TSumCol(j)/TSumCol(k))/(0.5*((i-k)^2-(i-j)^2)+1);
                        if lambda==+inf && (Maxj==0 || TSumCol(j)>TSumCol(Maxj)) || lambda>Maxlambda
                        %如果分母为0，则分割直方图最大的那个
                            Maxlambda=lambda;Maxi=i;Maxj=j;Maxk=k;
                        end
                    end
                end
            end
        end
        end
    end
    %Update
    if Maxlambda>0
        TDetect=T(Maxi,Maxj);
        if Maxlambda<0.5
            delta=0.125;
            if Maxlambda<0.05
                %可以略微修改矩阵
                for i=1:256
                    Column=T(i,find(T(i,:)>0));
                    while min(Column)<0.1*TSumRow(i)
                        clm=find(T(i,:)==min(Column),1,'first');
                        fract=T(i,clm);T(i,clm)=0;
                        Column=T(i,find(T(i,:)>0));%找第二小的值
                        clm=find(T(i,:)==min(Column),1,'first');T(i,clm)=T(i,clm)+fract;
                        Column=T(i,find(T(i,:)>0));%再次刷新，为执行循环的判断条件
                    end
                end
                  break;
            end
        else
            delta=min(0.2,TDetect);
        end
        T(Maxi,Maxj)=T(Maxi,Maxj)-delta;T(Maxi,Maxk)=T(Maxi,Maxk)+delta;
    else
        break;
    end
    if mod(IterationNum,50)==0 && dec==0
        [EntrophyX,EntrophyY]=entropy(T*512*512/2048);
        ENTRO(count)=EntrophyX-EntrophyY;
        rate(count) = (ENTRO(count))/row/col;
        [X]=outlook(T,ImgRev,512*512/2048);
%         X=uint8(X);
        [mssim(count), ~] = ssim(I,X);
        [mpcqi(count),~]=PCQI(I,X);
        count=count+1;
    end
    if wtbar==1
        waitbar(IterationNum/iterate,h,['Complete:' num2str(IterationNum/iterate*100) ',L=' num2str(Maxlambda)]);
    end
end

if dec==1
[EntrophyX,EntrophyY]=entropy(T*512*512/2048);
        ENTRO=EntrophyX-EntrophyY;
        rate = (ENTRO)/row/col;
        [X]=outlook(T,ImgRev,512*512/2048);
%         X=uint8(X);
        [mssim, ~] = ssim(I,X);
%         [mpcqi,~]=PCQI(I,X);
end
mpcqi=0;