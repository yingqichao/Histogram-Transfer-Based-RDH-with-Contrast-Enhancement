%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 获取图像
%%% by Dr. Zhenxing Qian in 2013.5
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ORG,filename,pathname]=loadim()

[filename,pathname]=uigetfile({'*.bmp; *.tif; *.tiff; *.jpg','(*.bmp);(*.tif);(*.tiff);(*.jpg)';},'打开图片');
if isequal(filename,0)
   disp('Image selection cancelled.');
   return;
else
   disp(['Image selected: ', fullfile(pathname, filename)])
end

ORG=imread([pathname,filename]); 




