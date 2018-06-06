%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%this version only consider allocating empty bins near 50 peaks.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [T,P,D]=RevMat(delta,iterate,H)
%——delta:step length of operation,iterate:number of iteration,H inputs as a vector.
size=length(H);D=0;
T=zeros(size,size);
%Initialize
for num=1:size
    T(num,num)=H(num);
end
%Calculate
h=waitbar(0,'Attend,s''il vous plait!');
for IterationNum=1:iterate
    iMax=0;jMax=0;kMax=0;lambdaMax=0;
    for i=1:size
        for j=1:size
            if T(i,j)>1%对于小于1的不做修改
                for k=1:size
                    if k~=j && (H(j)>H(k))
                        lambda=log2(H(j)/H(k))/(0.5*((i-k)^2-(i-j)^2)+1);
                        if lambda>lambdaMax
                            lambdaMax=lambda;iMax=i;jMax=j;kMax=k;
                        end
                    end
                end
            end
        end
    end
    %Update
    T(iMax,jMax)=T(iMax,jMax)-delta;T(iMax,kMax)=T(iMax,kMax)+delta;
    H=sum(T);
    waitbar(IterationNum/iterate,h,['Complete:' num2str(IterationNum/iterate*100) ',lambda=' num2str(lambdaMax)]);
    if lambdaMax<=0.05
        %可以略微修改矩阵
                RSum=sum(T,2);
                for i=1:size
                    Column=T(i,find(T(i,:)>0));
                    while min(Column)<0.1*RSum(i)
                        clm=find(T(i,:)==min(Column),1,'first');
                        fract=T(i,clm);T(i,clm)=0;
                        Column=T(i,find(T(i,:)>0));%找第二小的值
                        clm=find(T(i,:)==min(Column),1,'first');T(i,clm)=T(i,clm)+fract;
                        Column=T(i,find(T(i,:)>0));%再次刷新，为执行循环的判断条件
                    end
                end
        break;
    end
end
%Calculate distortion level D and payload level P
Sum_row=sum(T,2);Sum_col=sum(T);EntrophyY=0;EntrophyX=0;
Trows=zeros(size,size);Tcols=zeros(size,size);
for i=1:size
    if Sum_row(i)~=0
       for j=1:size
           Trows(i,j)=T(i,j)/Sum_row(i);
           if Trows(i,j)~=0
            EntrophyY=EntrophyY-Sum_row(i)*Trows(i,j)*log2(Trows(i,j));
           end
       end
    end
end
for j=1:size
    if Sum_col(j)~=0
       for i=1:size
           Tcols(i,j)=T(i,j)/Sum_col(j);
           if Tcols(i,j)~=0
            EntrophyX=EntrophyX-Sum_col(j)*Tcols(i,j)*log2(Tcols(i,j));
           end
       end
    end
end

P=EntrophyY-EntrophyX;
% for i=1:size
%     for j=1:size
%         if i~=j
%             D=D+T(i,j)^2;
%         end
%     end
% end

end
        
