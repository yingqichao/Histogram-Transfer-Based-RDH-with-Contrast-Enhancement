function [PSNR,MSE]=psnr(X,Y)
%%%%%%%%%%%%%%%%%%%%%%%%%%%??
%??
%?计算峰值信噪比PSNR??
%?将RGB转成YCbCr格式进行计算??
%?如果直接计算会比转后计算值要小2dB左右（当然是个别测试）??
%??
%%%%%%%%%%%%%%%%%%%%%%%%%%%??
if size(X,3)~=1%判断图像时不是彩色图，如果是，结果为3，否则为1??
org=rgb2ycbcr(X);
test=rgb2ycbcr(Y);
Y1=org(:,:,1);
Y2=test(:,:,1);
Y1=double(Y1);%计算平方时候需要转成double类型，否则uchar类型会丢失数据??
Y2=double(Y2);
else%灰度图像，不用转换??
Y1=double(X);
Y2=double(Y);
end
if nargin<2
D=Y1;
else
if any(size(Y1)~=size(Y2))
error('The?input?size?is?not?equal?to?each?other!');
end
D=Y1-Y2;
end
MSE=sum(D(:).*D(:))/numel(Y1);
PSNR=10*log10(255^2/MSE);