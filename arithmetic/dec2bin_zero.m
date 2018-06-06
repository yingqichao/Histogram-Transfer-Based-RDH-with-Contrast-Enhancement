function bin=dec2bin_zero(acode,nseq)
%========================================================================
% bin=dec2bin_zero(acode,nseq)
% Input: a decimal number (acode) and length of output binary sequence(nseq)
% Output: a binary sequence
% Author: William Ying
%----------------------------------------------------------------------
bin=[];
for i=1:nseq
   acode=acode*2;
   if acode>1
      bin(i)=1;
      acode=acode-1;
   else
      bin(i)=0;
   end
   if acode==0
       break;
   end
end


% function bin=dec2bin_zero(acode,nseq)%至少需要这个数，不保存之后的小数位
% bin=[];ex=0;i=1;
% while ex<EN
%     acode=acode*2;
%    if acode>1
%       bin(i)=1;
%       acode=acode-1;
%    else
%       bin(i)=0;
%    end
%     nseq=length(bin);
%     ZERO=length(find(bin(1:nseq)==0));ONE=nseq-ZERO;
%     if ZERO~=0 && ONE~=0
%       ex=-nseq*(ZERO/nseq*log2(ZERO/nseq)+ONE/nseq*log2(ONE/nseq));%表示code需要多少位
%     end
%     if ex>=EN%熵大于EN就退出，要求前几位没有误码
%         bin=bin(1:end-1);break;
%     end
%    i=i+1;
% end

