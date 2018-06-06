function [ stego,messLen,extraLen] = recursiveConstruct( Qxy,Qyx,cover,xRange,yRange,mB,mBratio )
%RECURSIVECONSTRUCT Summary of this function goes here
%   Detailed explanation goes here

N = length(cover);
mess = double( rand(3*N,1)<0.5 ); %the message

lenBlock = mB*mBratio;
numBlock = floor(N/lenBlock);

preMess = [];
preLen = length(preMess);

messPos = 0;
stego = cover;
for ib=1:numBlock
    cBlock = cover((ib-1)*lenBlock+1:ib*lenBlock);
    mBlock = preMess;

    mBlock(preLen+1:3*lenBlock) = mess(messPos+1:messPos+3*lenBlock-preLen);
    
    [sBlock,mLen] = entropyEmbed(cBlock,mBlock,Qxy,xRange,yRange);
    stego((ib-1)*lenBlock+1:ib*lenBlock) = sBlock;
    
    mLen = mLen - preLen;
    preMess = compressOhead(sBlock,cBlock,Qyx,xRange,yRange);
    preLen = length(preMess);
    messPos = messPos+mLen;
end

messLen = messPos;
extraLen = preLen;

end

