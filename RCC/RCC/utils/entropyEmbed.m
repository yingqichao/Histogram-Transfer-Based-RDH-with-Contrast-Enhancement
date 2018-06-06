function [ stego,mesLen ] = entropyEmbed( cover,mess,Qxy,xRange,yRange)
%ENTROPYEMBED Summary of this function goes here
%   Detailed explanation goes here
%   cover:  the cover signal
%   mess:   the message to embed
%   Qxy:    the conditional probability Py|x

stego = cover;
mesLen = 0;
[mB,nB] = size(Qxy);
for xi=1:mB
    pos = find(cover==xRange(xi));
    xN = length(pos);
    if xN>0
        yi = find(abs(Qxy(xi,:)-1.0) < eps);
        if yi
            stego(pos) = yRange(yi)*ones(xN,1);
        else%if abs(sum(Qxy(xi,:))-1.0)<1e-8
            fq = repmat(Qxy(xi,:),xN,1);
            [symbols,mLen] = arith_decode(mess(mesLen+1:end),fq);
            stego(pos) = yRange(symbols);
            mesLen = mesLen+mLen;
        end
    end
end



end

