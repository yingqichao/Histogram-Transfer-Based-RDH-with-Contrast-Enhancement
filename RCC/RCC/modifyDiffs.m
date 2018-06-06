function [ mod_diffs,messLen,lastLen] = modifyDiffs( diffs,bpp )
%MODIFYDIFFS Summary of this function goes here
%   Detailed explanation goes here%%%%%%%%%5ÐÞ¸Ä
addpath utils\;

cover = diffs;
minVal = min(cover);
maxVal = max(cover);

% x range form minVal to maxVal
hist = zeros(maxVal-minVal+1,1);
for x=minVal:maxVal
    hist(x-minVal+1) = sum(cover==x);
end

% truncate the histogram
threshT = max(400-bpp*800,10); % 400-bpp*50
good = (hist>=threshT);
L = find(good,1,'first')+minVal-1;
U = find(good,1,'last')+minVal-1;

pos = (cover>=L)&(cover<=U);
cover2 = cover(pos);
hist2 = zeros(U-L+1,1);
for x=L:U
    hist2(x-L+1) = sum(cover2==x);
end
lastLen = compressFun(hist2);  % compress histgram

N = length(cover2);
Px = hist2/N;
%bar(x,Px);

x = L:U;
y = L:U;
% squre error distortion matirx
mB = length(x);
nB = length(y);
Dxy=zeros(mB,nB);
for ii=1:mB
    for jj=1:nB
        Dxy(ii,jj) = (x(ii)-y(jj))*(x(ii)-y(jj));
    end
end

r = bpp;
Hx = -sum(Px.*log2(Px+eps));
rMax = log2(nB)-Hx;
if r>rMax
    r = rMax-0.01;
    disp('embedding rate exceeds maximum.');
end

% optimize to estimate Py
Hy = (r+Hx)*log(2);  % convert to logarithm based
Py = minDistortionEmr(Px,Dxy,Hy);

% non crossing edges property to get conditional probability Pxy and Pyx
[Qxy,Qyx] = nonCrossEdge(Px,Py);%%%%%%%%%% ²Ù×÷´Ë¾ä


% recursive embedding message
%
[stego,messLen,extraLen] = recursiveConstruct(Qxy,Qyx,cover2,x,y,mB,80);%75 150
messLen = messLen-extraLen;
%}

% or else just embedding once, not recursively... 
%{
mess = double(rand(3*N,1)<0.5);
stego= entropyEmbed(cover2,mess,Qxy,x,y);
messLen = r*N;
%}

cover(pos) = stego;
mod_diffs = cover;

end

