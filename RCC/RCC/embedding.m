function [ bpp,psnr,embedded ] = embedding( img,bpp )
%EMBEDDING Summary of this function goes here
%   Detailed explanation goes here

[waterMark,mesLen1] = imageEmbed(img,bpp,0);
[waterMark,mesLen2] = imageEmbed(waterMark,bpp,1);

origin = img(:);
embedded = waterMark(:);
psnr = 10*log10( 255*255*length(origin)/sum((embedded-origin).*(embedded-origin)) );

[m,n] = size(img);
bpp = (mesLen1+mesLen2)/(m*n);


end

