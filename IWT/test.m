Img=imread('lenagray.tif');
addpath 'C:\Users\yqc_s\Desktop\new';
[W,encode,auxlen,ImgOut]=IWTembed(Img);
[Z,code,auxlen1]=IWTdebed(Img,ImgOut);
