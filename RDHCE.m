function [CapSeq,SSIM,Pcqi,ImgSave,w_len]=RDHCE(ImgIn,ite,rate,filename,pathname)
addpath 'C:\Users\yqc_s\Desktop\new\PCQI';
addpath 'C:\Users\yqc_s\Desktop\new\functions';
addpath 'C:\Users\yqc_s\Desktop\gao\SPL15 Code- to yin\SPL15 Code- to yin';
[row,col]=size(ImgIn);SSIM=[];Pcqi=[];
CapSeq=nan(1,ite);Capability=0;cmp=+inf;Load=0;
% h=waitbar(0,'Please wait...');
ImgOut=ImgIn;
for IterationNum=1:ite
%     waitbar(IterationNum/ite);
    ImgOut=uint8(ImgOut);
    [Hist,x]=imhist(ImgOut,256);ImgOut=double(ImgOut);
    b=round(rand(1,100000));
    %find two peaks
    Hist(1)=0;Hist(256)=0;%不寻找最边上的灰度值
    Is=x(find(Hist==max(Hist),1,'first'));
    IsLen=Hist(Is+1);
    storation=Hist(Is+1);Hist(Is+1)=0;
    Ir=x(find(Hist==max(Hist),1,'last'));
    if Ir==0 || Ir==255
        msgbox('For peak index is 0 or 255. The image is abandoned!');
        return;
    end
    IrLen=Hist(Ir+1);
    storation=storation+Hist(Ir+1);Capability=Capability+storation;CapSeq(IterationNum)=Capability/row/col;
    Load=Load+storation-Hist(1)-Hist(2)-Hist(255)-Hist(256);
    if Is>Ir
        temp=Is;Is=Ir;Ir=temp; temp=IsLen;IsLen=IrLen;IrLen=temp; 
    end
    %move outside
    for i=1:row
        for j=1:col
            if ImgOut(i,j)>=1 && ImgOut(i,j)<=Is-1
                ImgOut(i,j)=ImgOut(i,j)-1;
            elseif ImgOut(i,j)>=Ir+1 && ImgOut(i,j)<=254
                ImgOut(i,j)=ImgOut(i,j)+1;
            end
        end
    end
    %split two peaks
    bCount=1;
    [r,c]=find(ImgOut==Is);
    for i=1:IsLen
        ImgOut(r(i),c(i))=Is-b(bCount);
        bCount=bCount+1;
    end
    [r,c]=find(ImgOut==Ir);
    for i=1:IrLen
        ImgOut(r(i),c(i))=Ir+b(bCount);
        bCount=bCount+1;
    end
    [mssim, ~] = ssim(ImgIn,ImgOut);[mpcqi, ~] = PCQI(ImgIn,ImgOut);
    SSIM=[SSIM mssim];Pcqi=[Pcqi mpcqi];
    %保存同等bpp下的对比图像
    if abs(CapSeq(IterationNum)-rate)<cmp
        cmp=abs(CapSeq(IterationNum)-rate);
        ImgSave=ImgOut;Loademb=Load;
    end
end
ImgSave=uint8(ImgSave);
imwrite(ImgSave,[pathname 'pic\' filename(1:end-4) '_compare.bmp']);
% % 
% % ===第2部分嵌入：在小波变换域高频嵌入===
% T_ini = 10; %12;%当T大于10时，可能导致溢出（>255 或<0）%考虑改为更大，以便嵌入更多信息，改阈值二值表示为8位
% Overhead_len_total=0;
% Payload_rate_total =0; 
% Payload_rate = 0.5; %预设置嵌入负载率,可以改变，一些图像可设大些（如Lena可预设位0.5,barbara设小些）
% LL =  ceil((5/4)*(T_ini+1));
% while 1
%     [img_histModi_1,Loca_map_1] = histogram_modi_1(ImgSave,LL);
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
%     img_name=filename;
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
% % 
% figure;
% imshow(uint8(img_ori_wm_restruct));
% imwrite(uint8(img_ori_wm_restruct),'IWT.bmp'); %Image embedded watermarking 
% % Overhead_len_total = Overhead_len_total + Overhead_len;
% % wm_len_total = pure_hide_wm_len_best + w_len;
% % disp(pure_hide_wm_len_best);
% disp(w_len);disp(Loademb);
% % fid = fopen('experiment_result.txt','a');
% % fprintf(fid,'\n%s: %s%0.3f %s%.2f %s%.3f %s%.4f %s%d %s%d',filename_WM, ...
% %     'pure hiding rate', Payload_rate_total,'psnr_val=',PSNR_wm,'mssim =',mssim_wm,'rce_val =',rce_val,'wm_all=',wm_len_total,'Overhead_all=',Overhead_len_total);
% % fclose(fid);
% measurement(ImgIn,uint8(img_ori_wm_restruct));
% 
