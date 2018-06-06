%%
%clc;close all;
% rate33=[];
% for i=1:147
%     if mod(i,3)==1 || mod(i,3)==0
%         rate33=[rate33 rate3(i)];
%     end
% end
% rate44=[];
% for i=1:112
%     if mod(i,11)==0
%         continue;
%     end
%     rate44=[rate44 rate4(i)];
% end
% rate3=rate33;rate4=rate44;
% rate11=rate1(10:10:end);rate22=rate2(10:10:end);rate33=rate3(10:10:end);rate44=rate4(10:10:end);
% 
% figure;
% x=50:50:50*length(rate1);
% y=500:500:500*length(rate11);
% plot(x,rate1,'-r');hold on;
% 
% x=50:50:50*length(rate2);
% 
% plot(x,rate2,'-b');
% 
% x=50:50:50*length(rate3);
% 
% plot(x,rate3,'-g');
% 
% x=50:50:50*length(rate4);
% 
% plot(x,rate4,'-c');
% 
% % print -dmeta filename
% legend('Lena','Baboon','Photographer','DSP','Location','SouthEast');
% y=500:500:500*length(rate11);plot(y,rate11,'.r');
% y=500:500:500*length(rate22);plot(y,rate22,'xb');
% y=500:500:500*length(rate33);plot(y,rate33,'og');
% y=500:500:500*length(rate44);plot(y,rate44,'dc');
% 
% % plot(x,HistOptimal','red');
% % hold on;
% % plot(x,Hist,'blue');
% print -dmeta 'disp';


addpath 'C:\Users\yqc_s\Desktop\new\IWT';
addpath 'C:\Users\yqc_s\Desktop\new\arithmetic';
addpath 'C:\Users\yqc_s\Desktop\new\functions';
addpath 'C:\Users\yqc_s\Desktop\new\PCQI';
addpath 'C:\Users\yqc_s\Desktop\new\PEE';
[ImgIn,filename,pathname]=loadim();
ImgIn=imresize(ImgIn,[512 512]);OriHist=imhist(ImgIn);
ImgIn=double(ImgIn);
[row,col]=size(ImgIn);
ImgOut=ImgIn;Hist=OriHist;PeakNum=50;
%记录零bin的位置（对于非0bin的相对位置，记录值为右侧非0bin是第几个非0，如果是最大值，则说明插在最右侧）
[HistSort,HistIdx]=sort(Hist);Zeros=length(find(Hist==0));OriZero=Zeros;
auxinfoZeroValue=[];
for i=1:Zeros
    BehindList=Hist(HistIdx(i):end);Behind=find(BehindList>0,1)+HistIdx(i)-1;
    if isempty(Behind)
        ZeroBefore=sum(HistIdx(1:Zeros)<256);Lc=256-ZeroBefore;
    else
        ZeroBefore=sum(HistIdx(1:Zeros)<Behind);Lc=Behind-ZeroBefore;
    end
    auxinfoZeroValue=[auxinfoZeroValue dec2bin(Lc,8)-48];
end
%图像预处理，将<=10的灰度与其他的合并(可以不做处理) %保存位置,value+flag+number+map
%说明：1.倒序插入 2.在每一步内，保存的位置为当前所在的非0bin的位置加减1
%先建立合并表，内含合并前灰度值与转移概率，后依据转移概率生成哈夫曼树，从前往后按照哈夫曼编码保存LM
auxinfoI=[];CombValue=[];CombNum=[];
disp('开始图像预处理：将<=20的灰度与其他的合并');
for i=1:256
  [rcomb,ccomb]=size(CombValue);
  if Hist(i)>0 && Hist(i)<=20
    HistMin=Hist(i);Hist(i)=0;
    [HistSort,HistIdx]=sort(Hist);
    FrontList=Hist(i:-1:1);BehindList=Hist(i:end);
    Front=i-find(FrontList>0,1)+1;Behind=find(BehindList>0,1)+i-1;
    abf=find(FrontList>0,1);abb=find(BehindList>0,1);
    if isempty(Behind)
        if isempty(find(CombValue==Front, 1)) && isempty(find(CombValue==i,1))
            CombValue(rcomb+1,1)=i;CombNum(rcomb+1,1)=OriHist(i);
            CombValue(rcomb+1,2)=Front;CombNum(rcomb+1,2)=OriHist(Front);
        elseif isempty(find(CombValue==Front, 1))
            [R,~]=find(CombValue==i, 1);
            CombValue(R,length(find(CombValue(R,:)>0))+1)=Front;CombNum(R,length(find(CombValue(R,:)>0)))=OriHist(Front);
        elseif isempty(find(CombValue==i, 1))
            [R,~]=find(CombValue==Front, 1);
            CombValue(R,length(CombValue(R,:))+1)=i;CombNum(R,length(CombValue(R,:)))=OriHist(i);
        else
            [R,~]=find(CombValue==Front, 1);[R1,~]=find(CombValue==i, 1);LEN=length(find(CombValue(R,:)>0));
            CombValue(R1,length(find(CombValue(R1,:)>0))+1:length(find(CombValue(R1,:)>0))+LEN)=CombValue(R,1:LEN);CombNum(R1,length(find(CombNum(R1,:)>0))+1:length(find(CombNum(R1,:)>0))+LEN)=CombNum(R,1:LEN);
            CombValue(R,:)=[];CombNum(R,:)=[];
        end
        ImgBuff=ImgOut;ImgOut=move(ImgOut,i-1,Front-1);Hist(Front)=Hist(Front)+HistMin;
%         LM=locationmap(ImgBuff,ImgOut,i-1,Front-1);
    elseif isempty(Front)
        if isempty(find(CombValue==Behind, 1)) && isempty(find(CombValue==i,1))
            CombValue(rcomb+1,1)=i;CombNum(rcomb+1,1)=OriHist(i);
            CombValue(rcomb+1,2)=Behind;CombNum(rcomb+1,2)=OriHist(Behind);
        elseif isempty(find(CombValue==Behind, 1))
            [R,~]=find(CombValue==i, 1);
            CombValue(R,length(find(CombValue(R,:)>0))+1)=Behind;CombNum(R,length(find(CombValue(R,:)>0)))=OriHist(Behind);
        elseif isempty(find(CombValue==i, 1))
            [R,~]=find(CombValue==Behind, 1);
            CombValue(R,length(find(CombValue(R,:)>0))+1)=i;CombNum(R,length(find(CombValue(R,:)>0)))=OriHist(i);
        else
            [R,~]=find(CombValue==Behind, 1);[R1,~]=find(CombValue==i, 1);LEN=length(find(CombValue(R,:)>0));
            CombValue(R1,length(find(CombValue(R1,:)>0))+1:length(find(CombValue(R1,:)>0))+LEN)=CombValue(R,1:LEN);CombNum(R1,length(find(CombNum(R1,:)>0))+1:length(find(CombNum(R1,:)>0))+LEN)=CombNum(R,1:LEN);
            CombValue(R,:)=[];CombNum(R,:)=[];
        end
        ImgBuff=ImgOut;ImgOut=move(ImgOut,i-1,Behind-1);Hist(Behind)=Hist(Behind)+HistMin;
%         LM=locationmap(ImgBuff,ImgOut,i-1,Behind-1);
    elseif Hist(Front)*abf<Hist(Behind)*abb
         if isempty(find(CombValue==Front, 1)) && isempty(find(CombValue==i,1))
            CombValue(rcomb+1,1)=i;CombNum(rcomb+1,1)=OriHist(i);
            CombValue(rcomb+1,2)=Front;CombNum(rcomb+1,2)=OriHist(Front);
        elseif isempty(find(CombValue==Front, 1))
            [R,~]=find(CombValue==i, 1);
            CombValue(R,length(find(CombValue(R,:)>0))+1)=Front;CombNum(R,length(find(CombValue(R,:)>0)))=OriHist(Front);
        elseif isempty(find(CombValue==i, 1))
            [R,~]=find(CombValue==Front, 1);
            CombValue(R,length(find(CombValue(R,:)>0))+1)=i;CombNum(R,length(find(CombValue(R,:)>0)))=OriHist(i);
        else
            [R,~]=find(CombValue==Front, 1);[R1,~]=find(CombValue==i, 1);LEN=length(find(CombValue(R,:)>0));
            CombValue(R1,length(find(CombValue(R1,:)>0))+1:length(find(CombValue(R1,:)>0))+LEN)=CombValue(R,1:LEN);CombNum(R1,length(find(CombNum(R1,:)>0))+1:length(find(CombNum(R1,:)>0))+LEN)=CombNum(R,1:LEN);
            CombValue(R,:)=[];CombNum(R,:)=[];
        end
        ImgBuff=ImgOut;ImgOut=move(ImgOut,i-1,Front-1);Hist(Front)=Hist(Front)+HistMin;
    else
         if isempty(find(CombValue==Behind, 1)) && isempty(find(CombValue==i,1))
            CombValue(rcomb+1,1)=i;CombNum(rcomb+1,1)=OriHist(i);
            CombValue(rcomb+1,2)=Behind;CombNum(rcomb+1,2)=OriHist(Behind);
        elseif isempty(find(CombValue==Behind, 1))
            [R,~]=find(CombValue==i, 1);
            CombValue(R,length(find(CombValue(R,:)>0))+1)=Behind;CombNum(R,length(find(CombValue(R,:)>0)))=OriHist(Behind);
        elseif isempty(find(CombValue==i, 1))
            [R,~]=find(CombValue==Behind, 1);
            CombValue(R,length(find(CombValue(R,:)>0))+1)=i;CombNum(R,length(find(CombValue(R,:)>0)))=OriHist(i);
        else
            [R,~]=find(CombValue==Behind, 1);[R1,~]=find(CombValue==i, 1);LEN=length(find(CombValue(R,:)>0));
            CombValue(R1,length(find(CombValue(R1,:)>0))+1:length(find(CombValue(R1,:)>0))+LEN)=CombValue(R,1:LEN);CombNum(R1,length(find(CombNum(R1,:)>0))+1:length(find(CombNum(R1,:)>0))+LEN)=CombNum(R,1:LEN);
            CombValue(R,:)=[];CombNum(R,:)=[];
        end
        ImgBuff=ImgOut;ImgOut=move(ImgOut,i-1,Behind-1);Hist(Behind)=Hist(Behind)+HistMin;
%         LM=locationmap(ImgBuff,ImgOut,i-1,Behind-1);
    end
  end
end
%保存Location Map
[~,HistIdx]=sort(Hist);Zeros=length(find(Hist==0));[R,C]=size(CombValue);CombNumBackup=CombNum;
for i=1:R
    for j=1:C
        CombNum(i,j)=CombNumBackup(i,j)/sum(CombNumBackup(i,:),2);
    end
end
for i=1:R
    LEN=length(find(CombValue(i,:)>0));
    CVMIN=min(CombValue(i,1:LEN));
    ZeroBefore=sum(HistIdx(1:Zeros)<CVMIN);Lc=CVMIN-ZeroBefore;
    pseq=CombNum(i,1:length(find(CombNum(i,:)>0)));
    core=huff(pseq);%建立哈夫曼表,保存码字用定长
        for k=1:512
            for l=1:512
                j=find(CombValue(i,1:LEN)==ImgIn(k,l)+1);
                if ~isempty(j)
                    auxinfoI=[auxinfoI core{j}-48];
                end
            end
        end   
    for j=LEN:-1:1
        auxinfoI=[dec2bin(CombNumBackup(i,j),4)-48 auxinfoI];
    end
    auxinfoI=[dec2bin(Lc,8)-48 auxinfoI];
end

x=1:1:256;CombValue=[];CombNum=[];
%就近合并最小的直方图，留出fra2个0位
disp(['开始合并最小的直方图，留出' num2str(PeakNum-Zeros) '个空位']);
for i=1:PeakNum-Zeros
[rcomb,ccomb]=size(CombValue);
    [HistSort,HistIdx]=sort(Hist);%为了寻找最小值
    HistMin=HistSort(i+Zeros);Index=HistIdx(i+Zeros);Hist(Index)=0;
    [HistSort,HistIdx]=sort(Hist);
    FrontList=Hist(Index:-1:1);BehindList=Hist(Index:end);
    Front=Index-find(FrontList>0,1)+1;Behind=find(BehindList>0,1)+Index-1;
    abf=find(FrontList>0,1);abb=find(BehindList>0,1);
    if isempty(Behind)
        if isempty(find(CombValue==Front, 1)) && isempty(find(CombValue==Index,1))
            CombValue(rcomb+1,1)=Index;CombNum(rcomb+1,1)=OriHist(Index);
            CombValue(rcomb+1,2)=Front;CombNum(rcomb+1,2)=OriHist(Front);
        elseif isempty(find(CombValue==Front, 1))
            [R,~]=find(CombValue==Index, 1);
            CombValue(R,length(find(CombValue(R,:)>0))+1)=Front;CombNum(R,length(find(CombValue(R,:)>0)))=OriHist(Front);
        elseif isempty(find(CombValue==Index, 1))
            [R,~]=find(CombValue==Front, 1);
            CombValue(R,length(CombValue(R,:))+1)=Index;CombNum(R,length(CombValue(R,:)))=OriHist(Index);
        else
            [R,~]=find(CombValue==Front, 1);[R1,~]=find(CombValue==Index, 1);LEN=length(find(CombValue(R,:)>0));
            CombValue(R1,length(find(CombValue(R1,:)>0))+1:length(find(CombValue(R1,:)>0))+LEN)=CombValue(R,1:LEN);CombNum(R1,length(find(CombNum(R1,:)>0))+1:length(find(CombNum(R1,:)>0))+LEN)=CombNum(R,1:LEN);
            CombValue(R,:)=[];CombNum(R,:)=[];
        end
        ImgBuff=ImgOut;ImgOut=move(ImgOut,Index-1,Front-1);Hist(Front)=Hist(Front)+HistMin;
%         LM=locationmap(ImgBuff,ImgOut,i-1,Front-1);
    elseif isempty(Front)
        if isempty(find(CombValue==Behind, 1)) && isempty(find(CombValue==Index,1))
            CombValue(rcomb+1,1)=Index;CombNum(rcomb+1,1)=OriHist(Index);
            CombValue(rcomb+1,2)=Behind;CombNum(rcomb+1,2)=OriHist(Behind);
        elseif isempty(find(CombValue==Behind, 1))
            [R,~]=find(CombValue==Index, 1);
            CombValue(R,length(find(CombValue(R,:)>0))+1)=Behind;CombNum(R,length(find(CombValue(R,:)>0)))=OriHist(Behind);
        elseif isempty(find(CombValue==Index, 1))
            [R,~]=find(CombValue==Behind, 1);
            CombValue(R,length(find(CombValue(R,:)>0))+1)=Index;CombNum(R,length(find(CombValue(R,:)>0)))=OriHist(Index);
        else
            [R,~]=find(CombValue==Behind, 1);[R1,~]=find(CombValue==Index, 1);LEN=length(find(CombValue(R,:)>0));
            CombValue(R1,length(find(CombValue(R1,:)>0))+1:length(find(CombValue(R1,:)>0))+LEN)=CombValue(R,1:LEN);CombNum(R1,length(find(CombNum(R1,:)>0))+1:length(find(CombNum(R1,:)>0))+LEN)=CombNum(R,1:LEN);
            CombValue(R,:)=[];CombNum(R,:)=[];
        end
        ImgBuff=ImgOut;ImgOut=move(ImgOut,Index-1,Behind-1);Hist(Behind)=Hist(Behind)+HistMin;
%         LM=locationmap(ImgBuff,ImgOut,i-1,Behind-1);
    elseif Hist(Front)*abf<Hist(Behind)*abb
         if isempty(find(CombValue==Front, 1)) && isempty(find(CombValue==Index,1))
            CombValue(rcomb+1,1)=Index;CombNum(rcomb+1,1)=OriHist(Index);
            CombValue(rcomb+1,2)=Front;CombNum(rcomb+1,2)=OriHist(Front);
        elseif isempty(find(CombValue==Front, 1))
            [R,~]=find(CombValue==Index, 1);
            CombValue(R,length(find(CombValue(R,:)>0))+1)=Front;CombNum(R,length(find(CombValue(R,:)>0)))=OriHist(Front);
        elseif isempty(find(CombValue==Index, 1))
            [R,~]=find(CombValue==Front, 1);
            CombValue(R,length(find(CombValue(R,:)>0))+1)=Index;CombNum(R,length(find(CombValue(R,:)>0)))=OriHist(Index);
        else
            [R,~]=find(CombValue==Front, 1);[R1,~]=find(CombValue==Index, 1);LEN=length(find(CombValue(R,:)>0));
            CombValue(R1,length(find(CombValue(R1,:)>0))+1:length(find(CombValue(R1,:)>0))+LEN)=CombValue(R,1:LEN);CombNum(R1,length(find(CombNum(R1,:)>0))+1:length(find(CombNum(R1,:)>0))+LEN)=CombNum(R,1:LEN);
            CombValue(R,:)=[];CombNum(R,:)=[];
        end
        ImgBuff=ImgOut;ImgOut=move(ImgOut,Index-1,Front-1);Hist(Front)=Hist(Front)+HistMin;
    else
         if isempty(find(CombValue==Behind, 1)) && isempty(find(CombValue==Index,1))
            CombValue(rcomb+1,1)=Index;CombNum(rcomb+1,1)=OriHist(Index);
            CombValue(rcomb+1,2)=Behind;CombNum(rcomb+1,2)=OriHist(Behind);
        elseif isempty(find(CombValue==Behind, 1))
            [R,~]=find(CombValue==Index, 1);
            CombValue(R,length(find(CombValue(R,:)>0))+1)=Behind;CombNum(R,length(find(CombValue(R,:)>0)))=OriHist(Behind);
        elseif isempty(find(CombValue==Index, 1))
            [R,~]=find(CombValue==Behind, 1);
            CombValue(R,length(find(CombValue(R,:)>0))+1)=Index;CombNum(R,length(find(CombValue(R,:)>0)))=OriHist(Index);
        else
            [R,~]=find(CombValue==Behind, 1);[R1,~]=find(CombValue==Index, 1);LEN=length(find(CombValue(R,:)>0));
            CombValue(R1,length(find(CombValue(R1,:)>0))+1:length(find(CombValue(R1,:)>0))+LEN)=CombValue(R,1:LEN);CombNum(R1,length(find(CombNum(R1,:)>0))+1:length(find(CombNum(R1,:)>0))+LEN)=CombNum(R,1:LEN);
            CombValue(R,:)=[];CombNum(R,:)=[];
        end
        ImgBuff=ImgOut;ImgOut=move(ImgOut,Index-1,Behind-1);Hist(Behind)=Hist(Behind)+HistMin;
%         LM=locationmap(ImgBuff,ImgOut,i-1,Behind-1);
    end
end
%保存Location Map
[~,HistIdx]=sort(Hist);Zeros=length(find(Hist==0));[R,C]=size(CombValue);CombNumBackup=CombNum;
for i=1:R
    for j=1:C
        CombNum(i,j)=CombNumBackup(i,j)/sum(CombNumBackup(i,:),2);
    end
end
for i=1:R
    LEN=length(find(CombValue(i,:)>0));
    CVMIN=min(CombValue(i,1:LEN));
    ZeroBefore=sum(HistIdx(1:Zeros)<CVMIN);Lc=CVMIN-ZeroBefore;
    pseq=CombNum(i,1:length(find(CombNum(i,:)>0)));
    core=huff(pseq);%建立哈夫曼表,保存码字用定长
        for k=1:512
            for l=1:512
                j=find(CombValue(i,1:LEN)==ImgIn(k,l)+1);
                if ~isempty(j)
                    auxinfoI=[auxinfoI core{j}-48];
                end
            end
        end   
    for j=LEN:-1:1
        auxinfoI=[dec2bin(CombNumBackup(i,j),4)-48 auxinfoI];
    end
    auxinfoI=[dec2bin(Lc,8)-48 auxinfoI];
end


ImgRev=zeros(size(ImgIn));
%无重合CE排列
disp('开始重新排列剩余灰度值，并在峰值边留空位');
HistNew=[];Trans=zeros(256,256);TransOrigin=zeros(256,256);
[HistSort,HistIdx]=sort(Hist);
HistPeak=HistIdx(end:-1:end+1-PeakNum);HistPeakValue=HistSort(end:-1:end+1-PeakNum);

for i=1:256
    if Hist(i)~=0
        HistNew=[HistNew Hist(i)];
        Trans(length(HistNew),length(HistNew))=Hist(i);
        [r,c]=find(ImgOut==i-1);
        for k=1:length(r)
            ImgRev(r(k),c(k))=length(HistNew)-1;
        end
        if ~isempty(find(HistPeak==i, 1))
            Trans(length(HistNew),length(HistNew))=0;HistNew=[HistNew 0];
            if i==256
                Trans(length(HistNew)-1,length(HistNew)-1)=Hist(i);%前插空
%                 Trans(length(HistNew)-1,length(HistNew))=0;
            elseif i==1
                Trans(length(HistNew),length(HistNew))=Hist(i);%后插空（前面修改的像素值需要+1）
%                 Trans(length(HistNew),length(HistNew)-1)=0;
                for k=1:length(r)
                    ImgRev(r(k),c(k))=ImgRev(r(k),c(k))+1;
                end
            elseif Hist(i-1)<Hist(i+1)
                Trans(length(HistNew)-1,length(HistNew)-1)=Hist(i);%前插空
%                 Trans(length(HistNew)-1,length(HistNew))=0;
            else
                Trans(length(HistNew),length(HistNew))=Hist(i);%后插空（前面修改的像素值需要+1）
%                 Trans(length(HistNew),length(HistNew)-1)=0;
                for k=1:length(r)
                    ImgRev(r(k),c(k))=ImgRev(r(k),c(k))+1;
                end
            end
        end
    end
end
%后续填0处理HistNew
disp('开始拟合原始直方图...');
Ones=find(Hist>0);HistWeight=0;HeadZeros=0;MinWeight=+inf;
for i=1:length(Ones)
    HistWeight=HistWeight+Ones(i)*Hist(Ones(i));
end
for i=0:256-length(HistNew)
    OutWeight=0;
    for j=1:length(HistNew)
        OutWeight=OutWeight+(i+j)*HistNew(j);
    end
    deltaWeight=abs(OutWeight-HistWeight);
    if deltaWeight<MinWeight
        MinWeight=deltaWeight;HeadZeros=i;
    end
end
len0=length(HistNew);

ImgRev=ImgRev+HeadZeros;
% ImgRev=uint8(ImgRev);%TM前的最终效果图
TransTemp=Trans;Trans=zeros(256,256);
Trans(HeadZeros+1:HeadZeros+len0,HeadZeros+1:HeadZeros+len0)=TransTemp(1:len0,1:len0);
for i=1:256
    HistNew(i)=Trans(i,i);
end
Trans=Trans*2048/(512*512);
for i=1:256
    for j=1:256
        if Trans(i,j)<=0.5 && Trans(i,j)>0
            Trans(i,j)=1;
        else
            Trans(i,j)=round(Trans(i,j));%量化矩阵以压缩转移矩阵的大小,Trans仍然是256*256
        end
    end
end

auxPreprocess=[dec2bin(OriZero,8)-48 auxinfoI auxinfoZeroValue];

%%
% Transfer Matrix
disp('开始计算转移矩阵，这可能需要一些时间...');

[T,rate,mssim,mpcqi,X]=Matrix(20000,Trans,1,0,ImgIn,ImgRev,row,col);
% for i=1:256
%     Sum=sum(T(i,:),2);
%     if Sum~=0
%         T(i,:)=T(i,:)/Sum;
%     end
% end
% PLOT1=1-T;
rate4=rate*512*512;

HistOptimal=sum(T*512*512/2048);
x=50:50:50*length(rate);
hold on,
% figure,imshow(PLOT1);
plot(rate*512*512)

% print -dmeta filename
% legend('A','B');
% plot(x,HistOptimal','red');
% hold on;
% plot(x,Hist,'blue');
% hold off;
% figure;
% subplot(1,2,1),plot(rate,mssim,'red');
% subplot(1,2,2),plot(rate,mpcqi,'red');
Realpayload=rate(end)*512*512-length(auxPreprocess);
% [bpp,SSIM,Pcqi,ImgComp,PurePayload]=RDHCE(ImgIn,50,rate(end),filename,pathname);
% [RCE(1),REE(1),RMBE(1)]=similarity(ImgIn,ImgComp);
% subplot(1,2,1),hold on,plot(bpp,SSIM,'blue'),hold off;
% subplot(1,2,2),hold on,plot(bpp,Pcqi,'blue'),hold off;

ImgIn=double(ImgIn);X=double(X);
[RCE,REE,RMBE]=similarity(ImgIn,X);
[RealSSIM, ~] = ssim(ImgIn,X);
[PSNR,~]=psnr(ImgIn,X);

% X=uint8(X);
% figure,imshow(X);


[RCE,REE,RMBE,PSNR,RealSSIM,ApproxPayload,ZZ]=PEEmain(ImgIn,X,filename,pathname,Realpayload);


% Z=uint8(Z);ImgIn=uint8(ImgIn);
% figure;
% subplot(1,3,1),imshow(ImgIn);
% subplot(1,3,2),imshow(ImgComp);
% subplot(1,3,3),imshow(Z);
% imwrite(Z,[pathname 'pic\' filename(1:end-4) '_target.bmp']);
disp(['嵌入完成！REE:' num2str(REE) ',RMBE:' num2str(RMBE) ',RCE:' num2str(RCE) ',PSNR:' num2str(PSNR) ',SSIM:' num2str(RealSSIM) ]);
disp(['Payload:' num2str(Realpayload+ApproxPayload)]);
disp(['图像预处理所需比特数：' num2str(length(auxPreprocess))]);
% figure,imshow(X);



% %%
% % embed algorithm
% % ImgRev=double(ImgRev);
% auxDeltaT=quantize(HistNew,PeakNum);
% %有时一个小块不足以保存所有LSB，因此可能需要多个小块才能隐藏信息
% BlockNum=1;
% disp(['当前辅助信息需要的LSB块个数：' num2str(BlockNum)]);
% lenAP=length(auxPreprocess);
% auxPreprocess=[dec2bin(lenAP,14)-48 auxPreprocess];
% false=0;
% while false==0
% disp('开始嵌入信息');
% futility_block=[];%无效的块号码
% Z=ImgRev;
% aux_info=[];aux_count=0;payload=[];
% code=round(rand(1,200000));code=[auxPreprocess code];CODE=code;
% [ps,replace,index]=ps_replace(T);%确定所有灰度值的转移概率与对应灰度值
% [ps1,replace1,index1]=ps_replace(T');%确定所有灰度值的转移概率与对应灰度值
% h=waitbar(0,'Encoding...');aux_extra=[];
% for block=0:63%将图像切分成64*64的64块
%       waitbar(block/64,h,['Block:' num2str(block+1)]);r_rev=64*(mod(block,8));c_rev=64*floor(block/8);%行列根据块的修正因子
%       payload_block=[];
%       if block==BlockNum%将block1的LSB写入从block1开始的恢复数据中
%           LSB=[];
%           for lsbBlock=1:BlockNum
%             lsbj_rev=(lsbBlock-1)*64;
%             for lsbi=1:64
%                 for lsbj=1:64
%                     LSB=[LSB mod(Z(lsbi,lsbj+lsbj_rev),2)];
%                 end
%             end
%           end
%           code=[LSB code];
%       end
%       if block~=0
%           code=[aux_info code];%第二个小块开始添加aux info
%           aux_count=aux_count+length(aux_info);
% %           aux_info=[];
%       end
% 
% %         H(Y|X)
%         Z1=ImgRev(r_rev+1:r_rev+64,c_rev+1:c_rev+64);
%         index0=[];
%         for qq=1:256%得到一一对应的先转换
%             if isempty(find(index==qq, 1)) && sum(T(qq,:),2)~=0
%                 index0=[index0 qq];
%             end
%         end
%         for qt=1:length(index0)
%             [r,c]=find(Z1==index0(qt)-1);%寻找像素时候-1
%             r0=find(T(index0(qt),:)>0);
%                for z=1:length(r)
%                    Z(r_rev+r(z),c_rev+c(z))=r0-1;%赋值时候-1
%                end
%         end
%         for q=1:length(index)
%             [r,c]=find(Z1==index(q)-1);%寻找像素时候-1
%             pseq=ps(index(q),1:find(ps(index(q),:),1,'last'));
%             core=huff(pseq);%建立哈夫曼表
%             corelen=[];
%             for icore=1:length(core)
%                 corelen(icore)=length(core{icore});%建立长度索引
%             end
%             for ir=1:length(r)
%                codestring='';
%                for iserlen=1:max(corelen)
%                   codestring=strcat(codestring,num2str(code(iserlen))); 
%                   coreindex=find(corelen==iserlen);watch=0;
%                   for ifind=1:length(coreindex)
%                      if strcmp(codestring,core{coreindex(ifind)})==1
%                          Z(r_rev+r(ir),c_rev+c(ir))=replace(index(q),coreindex(ifind))-1;%替换并-1
%                          payload_block=[payload_block code(1:iserlen)];
%                          code(1:iserlen)=[];watch=1;
%                          break; 
%                      end
%                   end
%                   if watch==1
%                     break;
%                   end
%                end
%             end
%         end
%         lenpay=length(payload_block);
%         if block~=0 && lenaux>lenpay%检查aux是否超出payload
%             futility_block=[futility_block block];
% %             则该块嵌入信息超出，还原并将aux第12位置1,包括了对block63的处理
%             aux_extra=aux_info(lenpay+1:end);
%             lenauxextra=length(aux_extra);
%             aux_extra_bin=dec2bin(lenauxextra,11)-48;
%             code(1:lenauxextra)=[];
%             aux_extra=[1 aux_extra_bin aux_extra];
%         end
%         aux_info=[];
% %         H(X|Y)
%         Z1=Z(r_rev+1:r_rev+64,c_rev+1:c_rev+64);%Z1已经经过修改
%         for q=1:length(index1)
%             [r,c]=find(Z1==index1(q)-1);%寻找像素时候-1
%             pseq=ps1(index1(q),1:find(ps1(index1(q),:),1,'last'));
%             core=huff(pseq);%建立哈夫曼
%             for ir=1:length(r)
%                origin=ImgRev(r_rev+r(ir),c_rev+c(ir));serie=find(replace1(index1(q),:)==origin+1);%读取数据+1
%                huffcode=core{serie};
%                for istore=1:length(huffcode)
%                   if  huffcode(istore)=='1'
%                       aux_info=[aux_info 1]; 
%                   else
%                       aux_info=[aux_info 0];
%                   end
%                end
%             end 
%         end
%         lenaux_bin=dec2bin(length(aux_info),12)-48;
%         aux_info=[lenaux_bin aux_info];lenaux=length(aux_info);
%         payload=[payload payload_block];
%         if ~isempty(aux_extra)
%             aux_info=[aux_extra aux_info];lenaux=length(aux_info);
%             aux_extra=[];
%         end   
% end
% % aux_count=aux_count+length(aux_info);
% %所有需要从图像中直接读取的辅助信息
% AUX=[dec2bin(BlockNum-1,1)-48 aux_info auxDeltaT];z=1;
% disp(['auxDeltaT长度：' num2str(length(auxDeltaT))]);
% disp(['auxPreprocess长度：' num2str(length(auxPreprocess))]);
% disp(['aux_info长度：' num2str(length(aux_info))]);
% Realpayload=length(payload)-aux_count-BlockNum*64*64-length(auxPreprocess);
% disp(['--->当前Payload：' num2str(Realpayload)]);
% if length(AUX)>(BlockNum*64*64)%如果超出，则上述过程无效，加一块LSB重新嵌入
%     BlockNum=BlockNum+1;
%     disp(['由于AUX长度超出当前各块大小，上述嵌入过程无效，正在重新嵌入。当前需要块数：' num2str(BlockNum)]);
% else
%     false=1;
% end
% end
% %以[BlockNum aux_info auxDeltaT auxPreprocess]来代替LSB
% disp('开始重写LSB数据...');
% for lsbBlock=1:BlockNum
%     lsbj_rev=(lsbBlock-1)*64;
%     for lsbi=1:64
%                  for lsbj=1:64
%                       Z(lsbi,lsbj+lsbj_rev)=Z(lsbi,lsbj+lsbj_rev)-mod(Z(lsbi,lsbj+lsbj_rev),2)+AUX(z);
%                       z=z+1;
%                       if z>length(AUX)
%                         break;
%                       end
%                  end
%                  if z>length(AUX)
%                       break;
%                  end
%     end
% end
% [RCE(2),REE(2),RMBE(2)]=similarity(ImgIn,Z);
% [RealSSIM, ~] = ssim(ImgIn,Z);
% % [RealPCQI, ~] = PCQI(ImgIn,Z);
% [PSNR,MSE]=psnr(ImgIn,Z);
% Z=uint8(Z);ImgIn=uint8(ImgIn);
% figure;
% subplot(1,3,1),imshow(ImgIn);
% subplot(1,3,2),imshow(ImgComp);
% subplot(1,3,3),imshow(Z);
% imwrite(Z,[pathname 'pic\' filename(1:end-4) '_target.bmp']);
% disp(['嵌入完成！REE:' num2str(REE(2)) ',RMBE:' num2str(RMBE(2)) ',RCE:' num2str(RCE(2)) ',PSNR:' num2str(PSNR) ',SSIM:' num2str(RealSSIM) ',PCQI:' num2str(RealPCQI)]);
% % print -dmeta filename
% 
% 
% %%
% % ===第2部分嵌入：在小波变换域高频嵌入===
% T_ini = 10; %12;%当T大于10时，可能导致溢出（>255 或<0）%考虑改为更大，以便嵌入更多信息，改阈值二值表示为8位
% Overhead_len_total=0;
% Payload_rate_total =0; 
% Payload_rate = 0.5; %预设置嵌入负载率,可以改变，一些图像可设大些（如Lena可预设位0.5,barbara设小些）
% LL =  ceil((5/4)*(T_ini+1));
% while 1
%     [img_histModi_1,Loca_map_1] = histogram_modi_1(double(Z),LL);
%      % ====  Perform integer LWT of the image + 计算量化误差  =====
%     [N,T,m,n,cA,coefQC_cH,coefQC_cV,coefQC_cD,e,cH,cV,cD] = lwt_QE(Loca_map_1,img_histModi_1,T_ini ,Payload_rate );
%     % == coefQC_cH,coefQC_cV,coefQC_cD 为 M*M cell结构  ==
%     % ==== 生成信息（Overhead（BDS+阈值T+量化误差e）+水印w）,判断是否满足嵌入负载率 ====
%     [Overhead_w,Overhead_len,w_len,overhead_toomuch] = generate_overhead_wm(Loca_map_1,T_ini ,N,m,n,e,Payload_rate);
%       
%     if overhead_toomuch==1  %不满足嵌入负载率
%        Payload_rate = Payload_rate - 0.05; %降低负载率,最终Payload_rate需告知解码端
%        PSNR_wm = 0;
%        continue;
%     end 
%     %-----先嵌入到LH子带，然后HL,HH子带-----
%     [coefQC_cHW,coefQC_cVW,coefQC_cDW] = embed_function(Overhead_w,m,n,coefQC_cH,coefQC_cV,coefQC_cD,N);
%     % ====  Perform integer ILWT of the image   =====    
%         img_name=filename;
%     [PSNR_wm,mssim_wm,img_ori_wm_restruct ] = ilwt_QE(cA,coefQC_cHW,coefQC_cVW,coefQC_cDW,img_name,Payload_rate ); 
% 
%     Payload_rate_total = Payload_rate;   
% %     Overhead_len_total = Overhead_len; 
% 
% %     filename_WM = sprintf('%s_%.3f%s%d%s%d%s',img_name,Payload_rate_total,'_L',L_best ,'_T',T_ini,'_WM.bmp');
%     max_pixelval = max(max(img_ori_wm_restruct)) ;
%     min_pixelval = min(min(img_ori_wm_restruct)) ;
%     if max_pixelval>255 || min_pixelval<0
%        LL = LL+1;  %溢出时增大直方图两端压缩量,需告知解码端 
%        disp('overflow');
%        continue;
%     else
%         break; %
%     end
% end
% % t_escape = toc;
% % disp('escape time for embedding:');
% % disp(t_escape); 
% 
% figure;
% imshow(uint8(img_ori_wm_restruct));
% imwrite(uint8(img_ori_wm_restruct),'IWT.bmp'); %Image embedded watermarking 
% % Overhead_len_total = Overhead_len_total + Overhead_len;
% % wm_len_total = pure_hide_wm_len_best + w_len;
% % disp(pure_hide_wm_len_best);
% disp(w_len);
% % fid = fopen('experiment_result.txt','a');
% % fprintf(fid,'\n%s: %s%0.3f %s%.2f %s%.3f %s%.4f %s%d %s%d',filename_WM, ...
% %     'pure hiding rate', Payload_rate_total,'psnr_val=',PSNR_wm,'mssim =',mssim_wm,'rce_val =',rce_val,'wm_all=',wm_len_total,'Overhead_all=',Overhead_len_total);
% % fclose(fid);
% measurement(ImgIn,uint8(img_ori_wm_restruct));
% 
% 
% %%
% %PEH Shifting
% % [RCE,REE,RMBE,PSNR,RealSSIM,RealPCQI,ZZ]=PEEmain(ImgIn,Z,filename,pathname,Realpayload);
% 
% 
% % %%
% % %IWT embed——test
% % Z=ImgIn;
% % [W,encode,auxlen,IO,V,H,D,A]=IWTembed(Z);
% % %%
% % %IWT decode
% % [IW,encodeCompare,auxlen1]=IWTdebed(W,IO,V,H,D,A);
% % Diff=double(IW)-double(ImgIn);
% % 
% % %
% % % decoding algorithm
% % debed=[];aux_extra=[];storage=[];
% % Z_recover=Z;
% % Trans_recover=dequantize(auxDeltaT);%2560bits
% % [T_quan_recover]=Matrix(20000,Trans,1,1);
% % 
% % dT=T-T_quan_recover;
% % 
% % h=waitbar(0,'Decoding...');
% % [ps,replace,index]=ps_replace(T_quan_recover);%确定所有灰度值的转移概率与对应灰度值
% % [ps1,replace1,index1]=ps_replace(T_quan_recover');%确定所有灰度值的转移概率与对应灰度值
% % for block=63:-1:0%将图像切分成32*32的64块
% %       waitbar((64-block)/64);r_rev=32*(mod(block,8));c_rev=32*floor(block/8);%行列根据块的修正因子
% % %       取出auxilary information
% %       if block~=63
% %           if debed(1)~=1
% %               lenaux=bin2dec(char(debed(1:12)+48));
% %               aux_info=debed(13:12+lenaux);
% %               lenauxextra=0;
% %           else
% %               lenauxextra=bin2dec(char(debed(2:12)+48));
% %               aux_extra=debed(13:12+lenauxextra);
% %               lenaux=bin2dec(char(debed(13+lenauxextra:24+lenauxextra)+48));
% %               aux_info=debed(25+lenauxextra:24+lenauxextra+lenaux);
% %           end
% %       else
% %           if aux_info(1)~=1
% %               lenaux=bin2dec(char(aux_info(1:12)+48));
% %               aux_info=aux_info(13:12+lenaux);lenauxextra=0;
% %           else
% %               lenauxextra=bin2dec(char(aux_info(2:12)+48));
% %               aux_extra=aux_info(13:12+lenauxextra);
% %               lenaux=bin2dec(char(aux_info(13+lenauxextra:24+lenauxextra)+48));
% %               aux_info=aux_info(25+lenauxextra:24+lenauxextra+lenaux);
% %           end
% %       end
% %       if lenaux+lenauxextra<length(debed)%取出嵌入信息
% %           if lenauxextra~=0
% %               storage=[debed(25+lenauxextra+lenaux:end) storage];
% %           else
% %               storage=[debed(13+lenaux:end) storage];
% %           end
% %       end
% %       debed=[];
% %         H(X|Y)
% %         Z1=Z(r_rev+1:r_rev+32,c_rev+1:c_rev+32);
% %         index0=[];
% %         for qq=1:256%得到一一对应的先转换
% %             if isempty(find(index1==qq, 1))
% %                 index0=[index0 qq];
% %             end
% %         end
% %         for qt=1:length(index0)
% %             [r,c]=find(Z1==index0(qt)-1);%寻找像素时候-1
% %             r0=find(T_quan_recover(:,index0(qt))>0);
% %                for z=1:length(r)
% %                    Z_recover(r_rev+r(z),c_rev+c(z))=r0-1;%赋值时候-1
% %                end
% %         end
% %         for q=1:length(index1)
% %            [r,c]=find(Z1==index1(q)-1);
% %             pseq=ps1(index1(q),1:find(ps1(index1(q),:),1,'last'));
% %             core=huff(pseq);%建立哈夫曼表
% %             corelen=[];
% %             for icore=1:length(core)
% %                 corelen(icore)=length(core{icore});%建立长度索引
% %             end
% %             for ir=1:length(r)
% %                codestring='';
% %                for iserlen=1:max(corelen)
% %                   codestring=strcat(codestring,num2str(aux_info(iserlen))); 
% %                   coreindex=find(corelen==iserlen);watch=0;
% %                   for ifind=1:length(coreindex)
% %                      if strcmp(codestring,core{coreindex(ifind)})==1
% %                          new=replace1(index1(q),coreindex(ifind))-1;
% %                          Z_recover(r_rev+r(ir),c_rev+c(ir))=new;%替换并-1
% %                          aux_info(1:iserlen)=[];watch=1;
% %                          break;
% %                      end
% %                   end
% %                   if watch==1
% %                     break;
% %                   end
% %                end
% %             end
% %         end
% % 
% %         %H(Y|X)
% %         I_recover=Z_recover(r_rev+1:r_rev+32,c_rev+1:c_rev+32);%是恢复图像的当前块
% % 
% %         for q=1:length(index)
% %             [r,c]=find(I_recover==index(q)-1);%寻找像素时候-1
% %             pseq=ps(index(q),1:find(ps(index(q),:),1,'last'));
% %             core=huff(pseq);%建立哈夫曼表
% %             for ir=1:length(r)
% %                new=Z1(r(ir),c(ir));serie=find(replace(index(q),:)==new+1);%读取数据+1
% %                huffcode=core{serie};
% %                for istore=1:length(huffcode)
% %                   if  huffcode(istore)=='1'
% %                       debed=[debed 1]; 
% %                   else
% %                       debed=[debed 0];
% %                   end
% %                end
% %             end 
% %         end
% %         if ~isempty(aux_extra)
% %            debed=[debed aux_extra];
% %            aux_extra=[];
% %         end
% %         imshow(Z_recover);
% % end
% % figure,imshow(Z_recover);
% % Zdiff=abs(Z_recover-ImgRev);
% % 
% % 
% % %
% % % reverse preprocessing according to auxPreprocess [Value flag LM ];
% % % 先移到最左边，再插空调整.flag左移为1，右移为0
% % Z_out=ImgRev;
% % HistZ=imhist(ImgRev);HistLeft=[];
% % for i=1:256
% %     if HistZ(i)~=0
% %         HistLeft=[HistLeft HistZ(i)];
% %         Z_out=move(Z_out,i-1,length(HistLeft)-1);
% %     end
% % end
% % OriZero=bin2dec(char(auxPreprocess(1:8)+48));auxPreprocess(1:8)=[];ZeroAdded=0;
% % while ~isempty(auxPreprocess)
% %     Value=bin2dec(char(auxPreprocess(1:8)+48))-1;auxPreprocess(1:8)=[];
% %     if length(auxPreprocess)>(OriZero*8)
% %         [r,c]=find(Z_out==Value);
% %         flag=auxPreprocess(1);auxPreprocess(1)=[];
% %         for i=255:-1:Value+flag%原bin右移到当前Value时，恢复时Value自身也需要+1，左移则不需要
% %             Z_out=move(Z_out,i,i+1);
% %         end
% %         HistLeft=imhist(Z_out);
% %         for i=1:length(r)
% %             if auxPreprocess(1)==1
% %                 if flag==1
% %                     Z_out(r(i),c(i))=Z_out(r(i),c(i))+1;
% %                 else
% %                     Z_out(r(i),c(i))=Z_out(r(i),c(i))-1;
% %                 end
% %             end
% %             auxPreprocess(1)=[];
% %         end
% %     else
% %         for i=255:-1:Value+ZeroAdded%原bin右移到当前Value时，恢复时Value自身也需要+1，左移则不需要
% %             Z_out=move(Z_out,i,i+1);
% %         end
% %         HistLeft=imhist(Z_out);ZeroAdded=ZeroAdded+1;
% %     end
% % end
% % figure,imshow(Z_out);
% % figure,imshow(Z_out-ImgIn);
% 
% % print -dmeta filename