function [Z,code,auxlen1]=IWTdebed(Img,ImgOut)
I=double(Img);
[V,H,D,A]=IWT(I);%A²»ÓÃ
code=[];[r,~]=size(V);
T=bin2dec(char([mod(V(1,1),2) mod(H(1,1),2) mod(D(1,1),2) mod(V(1,2),2) mod(H(1,2),2)]+48));
delta=3*ceil(1.25*(T+2));
for i=1:r
    for j=1:r
        code=[code mod(V(i,j),2) mod(H(i,j),2) mod(D(i,j),2)];
        V(i,j)=(V(i,j)-mod(V(i,j),2))/2;
        H(i,j)=(H(i,j)-mod(H(i,j),2))/2;
        D(i,j)=(D(i,j)-mod(D(i,j),2))/2;
        if abs(V(i,j))>T%expand
            if V(i,j)>0
               V(i,j)=2*abs(V(i,j))-T; 
            else
               V(i,j)=-(2*abs(V(i,j))-T); 
            end
        end
        if abs(H(i,j))>T
            if H(i,j)>0
               H(i,j)=2*abs(H(i,j))-T; 
            else
               H(i,j)=-(2*abs(H(i,j))-T); 
            end
        end
        if abs(D(i,j))>T
            if D(i,j)>0
               D(i,j)=2*abs(D(i,j))-T; 
            else
               D(i,j)=-(2*abs(D(i,j))-T); 
            end
        end
    end
end
%decoding
code(1:5)=[];
lenV=bin2dec(char(code(1:12)+48));Vcmp=code(13:12+lenV*8);code(1:12+lenV*8)=[];RLCV=zeros(lenV,1);
for i=1:lenV
    RLCV(i)=bin2dec(char(Vcmp(1:8)+48));Vcmp(1:8)=[];
end
lenH=bin2dec(char(code(1:12)+48));Hcmp=code(13:12+lenH*8);code(1:12+lenH*8)=[];RLCH=zeros(lenH,1);
for i=1:lenH
    RLCH(i)=bin2dec(char(Hcmp(1:8)+48));Hcmp(1:8)=[];
end
lenD=bin2dec(char(code(1:12)+48));Dcmp=code(13:12+lenD*8);code(1:12+lenD*8)=[];RLCD=zeros(lenD,1);
for i=1:lenD
    RLCD(i)=bin2dec(char(Dcmp(1:8)+48));Dcmp(1:8)=[];
end
Vcmp = Arith07(RLCV);Hcmp = Arith07(RLCH);Dcmp = Arith07(RLCD);
%revise V H D
for i=1:r
    for j=1:r
        if Vcmp((i-1)*r+j)==1
            if V(i,j)>0
                V(i,j)=V(i,j)+1;
            else
                V(i,j)=V(i,j)-1;
            end
        end
        if Hcmp((i-1)*r+j)==1
            if H(i,j)>0
                H(i,j)=H(i,j)+1;
            else
                H(i,j)=H(i,j)-1;
            end
        end
        if Dcmp((i-1)*r+j)==1
            if D(i,j)>0
                D(i,j)=D(i,j)+1;
            else
                D(i,j)=D(i,j)-1;
            end
        end
    end
end
Z=IIWT(V,H,D,A);auxlen1=0;
for k=0+delta:delta-1+delta
    [r,c]=find(Z==k);auxlen1=auxlen1+length(r);
    for i=1:length(r)
            if code(1)==1
                    Z(r(i),c(i))=Z(r(i),c(i))-delta;
            end
            code(1)=[];
     end
end
for k=256-delta-delta:255-delta
    [r,c]=find(Z==k);auxlen1=auxlen1+length(r);
    for i=1:length(r)
            if code(1)==1
                    Z(r(i),c(i))=Z(r(i),c(i))+delta;
            end
            code(1)=[];
     end
end
Z=uint8(Z);
figure,
subplot(2,1,1),imshow(Z);
subplot(2,1,2),imshow(Z-Img);

