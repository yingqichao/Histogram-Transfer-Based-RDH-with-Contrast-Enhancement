% decoding algorithm
%calculate the new quantized PEH
clc;close all;
addpath 'C:\Users\yqc_s\Desktop\new\IWT';
addpath 'C:\Users\yqc_s\Desktop\new\arithmetic';
addpath 'C:\Users\yqc_s\Desktop\new\functions';
addpath 'C:\Users\yqc_s\Desktop\new\PCQI';
addpath 'C:\Users\yqc_s\Desktop\new\PEE';
Z=loadim();Z=double(Z);
Ie=zeros(size(Z));
%from LSB extrast aux info
aux_info=[];
for lsbi=1:64
                 for lsbj=1:64
                      aux_info=[aux_info mod(Z(lsbi,lsbj),2)];
                 end
end
seq=zeros(4,1);
for i=1:4
    seq(i)=bin2dec_zero(aux_info(1:8));
    aux_info(1:8)=[];
end
for i=2:r-1
        for j=2:c-1
            if mod((i+j),2)==flag
                Ie(i,j)=round((seq(1)*Z(i-1,j)+seq(2)*Z(i,j-1)+seq(3)*Z(i+1,j)+seq(4)*Z(i,j+1)-Z(i,j)));
            end
        end
end
emin=min(min(Ie));emax=max(max(Ie));y=emin:emax;
newPEH=zeros(emax-emin+1,1);
for i=2:512-1
        for j=2:512-1
            if mod((i+j),2)==1
                idx=Ie(i,j)-emin+1;
                newPEH(idx)=newPEH(idx)+1;
            end
        end
end
thresh=round(512*512/4096);i=1;
while i<=length(newPEH)
    if newPEH(i)<thresh
        newPEH(i)=[];y(i)=[];
    else
        i=i+1;
    end
end
newPEH=round(newPEH*2048/(512*512));lenPEH=length(newPEH);PEH=zeros(lenPEH,1);
for i=1:lenPEH
    delta=bin2dec(aux_info(2:7)+48);
    if aux_info(1)==1
        delta=-delta;
    end
    aux_info(1:7)=[];PEH(i)=newPEH(i)+delta;
end
lenz=aux_info(1:12);aux_info=aux_info(1:12+lenz);
%calculate the transfer matrix
debed=[];aux_extra=[];storage=[];
Z_recover=Z;
[T_quan_recover,~,~,~]=RevMat(0.125,40000,PEH);

%%
%Set B recovery——not finished
h=waitbar(0,'Decoding...');
[ps,replace,index]=ps_replace(T_quan_recover);%确定所有灰度值的转移概率与对应灰度值
[ps1,replace1,index1]=ps_replace(T_quan_recover');%确定所有灰度值的转移概率与对应灰度值
for block=63:-1:0%将图像切分成32*32的64块
      waitbar((64-block)/64);r_rev=32*(mod(block,8));c_rev=32*floor(block/8);%行列根据块的修正因子
%       取出auxilary information
      if block~=63
          if debed(1)~=1
              lenaux=bin2dec(char(debed(1:12)+48));
              aux_info=debed(13:12+lenaux);
              lenauxextra=0;
          else
              lenauxextra=bin2dec(char(debed(2:12)+48));
              aux_extra=debed(13:12+lenauxextra);
              lenaux=bin2dec(char(debed(13+lenauxextra:24+lenauxextra)+48));
              aux_info=debed(25+lenauxextra:24+lenauxextra+lenaux);
          end
      else
          if aux_info(1)~=1
              lenaux=bin2dec(char(aux_info(1:12)+48));
              aux_info=aux_info(13:12+lenaux);lenauxextra=0;
          else
              lenauxextra=bin2dec(char(aux_info(2:12)+48));
              aux_extra=aux_info(13:12+lenauxextra);
              lenaux=bin2dec(char(aux_info(13+lenauxextra:24+lenauxextra)+48));
              aux_info=aux_info(25+lenauxextra:24+lenauxextra+lenaux);
          end
      end
      if lenaux+lenauxextra<length(debed)%取出嵌入信息
          if lenauxextra~=0
              storage=[debed(25+lenauxextra+lenaux:end) storage];
          else
              storage=[debed(13+lenaux:end) storage];
          end
      end
      debed=[];
%         H(X|Y)
        Z1=Z(r_rev+1:r_rev+32,c_rev+1:c_rev+32);
        for q=1:length(y(index1))
           [r,c]=find(Z1==index1(q)-1);
            pseq=ps1(index1(q),1:find(ps1(index1(q),:),1,'last'));
            core=huff(pseq);%建立哈夫曼表
            corelen=[];
            for icore=1:length(core)
                corelen(icore)=length(core{icore});%建立长度索引
            end
            for ir=1:length(r)
               codestring='';
               for iserlen=1:max(corelen)
                  codestring=strcat(codestring,num2str(aux_info(iserlen))); 
                  coreindex=find(corelen==iserlen);watch=0;
                  for ifind=1:length(coreindex)
                     if strcmp(codestring,core{coreindex(ifind)})==1
                         new=replace1(index1(q),coreindex(ifind))-1;
                         Z_recover(r_rev+r(ir),c_rev+c(ir))=new;%替换并-1
                         aux_info(1:iserlen)=[];watch=1;
                         break;
                     end
                  end
                  if watch==1
                    break;
                  end
               end
            end
        end

        %H(Y|X)
        I_recover=Z_recover(r_rev+1:r_rev+32,c_rev+1:c_rev+32);%是恢复图像的当前块

        for q=1:length(index)
            [r,c]=find(I_recover==index(q)-1);%寻找像素时候-1
            pseq=ps(index(q),1:find(ps(index(q),:),1,'last'));
            core=huff(pseq);%建立哈夫曼表
            for ir=1:length(r)
               new=Z1(r(ir),c(ir));serie=find(replace(index(q),:)==new+1);%读取数据+1
               huffcode=core{serie};
               for istore=1:length(huffcode)
                  if  huffcode(istore)=='1'
                      debed=[debed 1]; 
                  else
                      debed=[debed 0];
                  end
               end
            end 
        end
        if ~isempty(aux_extra)
           debed=[debed aux_extra];
           aux_extra=[];
        end
        imshow(Z_recover);
end
figure,imshow(Z_recover);
Zdiff=abs(Z_recover-ImgRev);