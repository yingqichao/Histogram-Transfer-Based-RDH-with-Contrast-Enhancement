%%%%%%%%This is a demo for the usage of PCQI with default settings%%%%%%%%%%%%%%%%%%
addpath 'C:\Users\yqc_s\Desktop\new';

im1=imread('lenagray.tif');
im2=imread('compare.bmp');
im3=imread('target.bmp');
im1=double(im1);
im2=double(im2);
im3=double(im3);
[mpcqi(1),~]=PCQI(im1,im2);
[mpcqi(2),~]=PCQI(im1,im3);
