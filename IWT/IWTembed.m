function [W,encode,auxlen,ImgOut]=IWTembed(Img)
% Img=imread('lena.jpg');
% Img=rgb2gray(Img);
I=double(Img);auxLM=[];ImgOut=I;Hist=imhist(Img);
code=round(rand(1,500000));k=1;encode=[];
[V,H,D,A]=IWT(I);%A不用
[r,~]=size(V);
Vcmp=zeros(size(V));Hcmp=zeros(size(V));Dcmp=zeros(size(V));
Vrev=zeros(size(V));Hrev=zeros(size(V));Drev=zeros(size(V));
Vrecover=zeros(size(V));Hrecover=zeros(size(V));Drecover=zeros(size(V));
%寻找合适的T
T=1;
while((sum(Hist(1:6*ceil(1.25*(T+2))))+sum(Hist(end:end-6*ceil(1.25*(T+2))+1)))<(r*r/10))
    T=T+1;
end
T=T-1;
delta=3*ceil(1.25*(T+2));%location map,最大偏移
for i=0:delta-1
    ImgBuff=ImgOut;ImgOut=move(ImgOut,i,i+delta);LM=locationmap(ImgBuff,ImgOut,i,i+delta);
    auxLM=[auxLM LM];
end
for i=256-delta:255
    ImgBuff=ImgOut;ImgOut=move(ImgOut,i,i-delta);LM=locationmap(ImgBuff,ImgOut,i,i-delta);
    auxLM=[auxLM LM];
end
auxlen=length(auxLM);code=[auxLM code];
for i=1:r
    for j=1:r
        if abs(V(i,j))>T%compress
            if V(i,j)>0
               Vrev(i,j)=floor((abs(V(i,j))-T)/2)+T;Vrecover(i,j)=2*abs(Vrev(i,j))-T;
            else
               Vrev(i,j)=-(floor((abs(V(i,j))-T)/2)+T);Vrecover(i,j)=-2*abs(Vrev(i,j))+T;
            end
            Vcmp(i,j)=V(i,j)-Vrecover(i,j);
        end
        if abs(H(i,j))>T
            if H(i,j)>0
               Hrev(i,j)=floor((abs(H(i,j))-T)/2)+T;Hrecover(i,j)=2*abs(Hrev(i,j))-T;
            else
               Hrev(i,j)=-(floor((abs(H(i,j))-T)/2)+T);Hrecover(i,j)=-2*abs(Hrev(i,j))+T; 
            end
            Hcmp(i,j)=H(i,j)-Hrecover(i,j);
        end
        if abs(D(i,j))>T
            if D(i,j)>0
               Drev(i,j)=floor((abs(D(i,j))-T)/2)+T;Drecover(i,j)=2*abs(Drev(i,j))-T; 
            else
               Drev(i,j)=-(floor((abs(D(i,j))-T)/2)+T);Drecover(i,j)=-2*abs(Drev(i,j))+T; 
            end
            Dcmp(i,j)=D(i,j)-Drecover(i,j);
        end      
    end
end
%lixiaolong's coding
RLC=[];RLCV=[];RLCH=[];RLCD=[];
Vcmp=abs(Vcmp');Hcmp=abs(Hcmp');Dcmp=abs(Dcmp');Vcmp=Vcmp(:);Hcmp=Hcmp(:);Dcmp=Dcmp(:);
xV={Vcmp};xH={Hcmp};xD={Dcmp};
[RV,~] = Arith07(xV);
[RH,~] = Arith07(xH);
[RD,~] = Arith07(xD);
for i=1:length(RV)
       RLCV=[RLCV dec2bin(RV(i),8)-48]; 
end
RLCV=[dec2bin(length(RV),12)-48 RLCV];
for i=1:length(RH)
       RLCH=[RLCH dec2bin(RH(i),8)-48]; 
end
RLCH=[dec2bin(length(RH),12)-48 RLCH];
for i=1:length(RD)
       RLCD=[RLCD dec2bin(RD(i),8)-48]; 
end
RLCD=[dec2bin(length(RD),12)-48 RLCD];
RLC=[dec2bin(T,5)-48 RLCV RLCH RLCD];
code=[RLC code];
for i=1:r
    for j=1:r
        V(i,j)=2*V(i,j)+code(k);k=k+1;
        H(i,j)=2*H(i,j)+code(k);k=k+1;
        D(i,j)=2*D(i,j)+code(k);k=k+1;
        encode=[encode code(k-3:k-1)];
    end
end
W=IIWT(V,H,D,A);
W=uint8(W);
figure,
subplot(2,1,1),imshow(Img);
subplot(2,1,2),imshow(W,[]),title(num2str(k));
disp(['IWT嵌入数据：' num2str(r*r*3-length(RLC)-auxlen)]);
