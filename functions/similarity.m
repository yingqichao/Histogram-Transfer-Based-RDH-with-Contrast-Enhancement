%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Calculate similarity index.
%%% Inputs:I,W
%%% Outputs:RCE,REE,RMBE,RSS
%%% 2017.10.1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [RCE,REE,RMBE]=similarity(I,W)
[row,col]=size(I);
H_ori=imhist(uint8(I));H_rev=imhist(W);
Entrophy_before=H_of_X(H_ori);%—È÷§¡ÀH(Y)-H(X)=H(Y|X)-H(X|Y)
Entrophy_after=H_of_X(H_rev);
Mean_I=sum(sum(I))/row/col;Mean_W=sum(sum(W))/row/col;
std_I=standard(I);std_W=standard(W);
RCE=(std_W-std_I)/255+0.5;
REE=(abs(Entrophy_before-Entrophy_after))/(2*log2(255)*row*col)+0.5;
RMBE=1-abs(Mean_I-Mean_W)/255;