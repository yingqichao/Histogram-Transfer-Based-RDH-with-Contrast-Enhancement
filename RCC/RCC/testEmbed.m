close all;clc;clear;

img = imread('lena.tif');
% check if is gray image
[imh,imw,imc] = size(img);
assert(imc==1);

img = double(img);

Zh_lena = zeros(50,2);
ind = 0;
for hr=0.11:0.1:1 % embedding rate
    [b,p,embedded] = embedding(img,hr);
    %as=double(embedded)-double(img(:));
    disp([hr b p]);
    if b>0
        ind = ind+1;
        Zh_lena(ind,1) = b;
        Zh_lena(ind,2) = p;
    end
end
Zh_lena=Zh_lena(1:ind,:);


figure;
plot(Zh_lena(:,1),Zh_lena(:,2),'-r.');grid on;