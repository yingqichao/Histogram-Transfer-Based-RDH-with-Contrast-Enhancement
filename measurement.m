function measurement(OriIm,ImgCmp)
addpath 'C:\Users\yqc_s\Desktop\new\IWT';
addpath 'C:\Users\yqc_s\Desktop\new\arithmetic';
addpath 'C:\Users\yqc_s\Desktop\new\functions';
addpath 'C:\Users\yqc_s\Desktop\new\PCQI';
addpath 'C:\Users\yqc_s\Desktop\new\PEE';
% OriIm=loadim();ImgCmp=loadim();
[RCE,REE,RMBE]=similarity(OriIm,ImgCmp);
[SSIM, ~] = ssim(OriIm,ImgCmp);
% [PCQI, ~] = PCQI(double(OriIm),double(ImgCmp));
[PSNR,~]=psnr(OriIm,ImgCmp);
disp(['RCE REE RMBE SSIM PSNR=' num2str(RCE) num2str(REE) num2str(RMBE) num2str(SSIM) num2str(PSNR)]);