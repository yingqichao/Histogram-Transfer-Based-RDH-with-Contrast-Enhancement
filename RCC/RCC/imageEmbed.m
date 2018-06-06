function [ waterMark,messLen ] = imageEmbed( img,bpp,dir)
%IMAGEEMBED Summary of this function goes here
%   Detailed explanation goes here

waterMark = img;
[row,col] = size(img);

preV = zeros(row*col/2,1);
difs = zeros(row*col/2,1);
xpos = zeros(row*col/2,1);
ypos = zeros(row*col/2,1);


pfor=0;
I = img;
for i=2:row-1
    if dir+mod(i,2)==2
        k=0;
    else
        k=dir+mod(i,2);
    end
    for j=2+k:2:col-1

        pre=predict(I(i-1,j),I(i,j-1),I(i+1,j),I(i,j+1));
        %difs_temp=I(i,j)-pre;
        
        %if ~(I(i,j)==0&&difs_temp<=0) && ~(I(i,j)==255&&difs_temp>=0)
            pfor=pfor+1;
            difs(pfor)=I(i,j)-pre;
            xpos(pfor)=i;
            ypos(pfor)=j;
            preV(pfor)=pre;

        %end
        %end
    end
end

overLen = 4000;
[mod_diffs,messLen,nLast] = modifyDiffs(difs(1:pfor-overLen),bpp);
mod_diffs = [mod_diffs;difs(pfor-overLen+1:pfor)];

%% overflow and underflow handling
pforInd = sub2ind(size(waterMark),xpos(1:pfor-overLen),ypos(1:pfor-overLen));
waterMark(pforInd) = preV(1:pfor-overLen)+mod_diffs(1:pfor-overLen);
fLen = sum( waterMark(pforInd)<0 | waterMark(pforInd)>255 );
tmp = waterMark(pforInd);
tmp(tmp<0)=0;tmp(tmp>255)=255;
waterMark(pforInd)=tmp;

allLen = sum(waterMark(pforInd)==0 | waterMark(pforInd)==255);
op = fLen/(allLen+eps);
headLen = -(op*log2(op+eps)+(1-op)*log2(1-op+eps));
headLen = ceil(allLen*headLen)+nLast+20;

% lsb substitute
oh = (rand(headLen,1)>0.5);
tmp = preV(pfor-headLen+1:pfor); %oh = ~mod(tmp,2);
tmp =2*floor(tmp/2)+oh;
preV(pfor-headLen+1:pfor) = tmp;
lsbInd = sub2ind(size(waterMark),xpos(pfor-headLen+1:pfor),ypos(pfor-headLen+1:pfor));
waterMark(lsbInd) = preV(pfor-headLen+1:pfor)+mod_diffs(pfor-headLen+1:pfor);

if headLen>overLen
    disp('too large headLen');
    disp(headLen-overLen);
end
messLen = messLen-headLen;

end

