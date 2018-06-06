function [ compSeq ] = compressOhead( stego,cover,Qyx,xRange,yRange)
%COMPRESSOHEAD Summary of this function goes here
%   Detailed explanation goes here

[nB,mB]=size(Qyx);

coverLen = length(cover);
coverind = zeros(coverLen,1);
for xi=1:mB
    coverind(cover==xRange(xi)) = xi;
end
cover = coverind;

compSeq = zeros(coverLen,1);
compLen = 0;
for yi=1:nB
    pos = find(stego==yRange(yi));
     if ~isempty(pos) && ~any(abs(Qyx(yi,:)-1.0)<eps) %&& abs(sum(Qyx(yi,:))-1.0)<1e-8
        source = cover(pos);
        fq = repmat(Qyx(yi,:),length(source),1);
        compT = arith_encode(source,fq);
        
        lenT = length(compT);
        compSeq(compLen+1:compLen+lenT) = compT;
        compLen = compLen+lenT;
    end
end
compSeq = compSeq(1:compLen);

end

