function Ty=dequantize(auxDeltaT)%[8 8 9]
PeakNum=bin2dec(char(auxDeltaT(1:8)+48));ZERO=bin2dec(char(auxDeltaT(9:16)+48))-1;
Ty=zeros(256,256);
auxDeltaT(1:25)=[];%[PeakNum zeros lenZ]
j=length(auxDeltaT)/12;HistDelta=[];HistNew=[];H1=0;
for i=1:j
    value=bin2dec(char(auxDeltaT(2:12)+48));k=1;
    if auxDeltaT(1)==1
        value=-value;
    end
    while abs(value)==k*(2^11)
       value=abs(value);
       auxDeltaT(1:12)=[];
       value=value+bin2dec(char(auxDeltaT(2:12)+48));
       if auxDeltaT(1)==1
          value=-value;
       end
       k=k+1;
    end
    H2=H1+value;
    auxDeltaT(1:12)=[];
    HistDelta(i)=H2;
    H1=H2;
end
for i=1:ZERO
    HistNew=[0 HistNew];
end
[HistSort,HistIdx]=sort(HistDelta);
PeakValue=HistSort(end-PeakNum+1:end);
for i=1:length(HistDelta)
    HistNew=[HistNew HistDelta(i)];
    if ~isempty(find(PeakValue==HistDelta(i), 1))
            if i==length(HistDelta)
                HistNew=[HistNew 0];
            elseif i==1
                last=HistNew(end);HistNew(end)=[];
                HistNew=[HistNew 0 last];
            elseif HistDelta(i-1)<HistDelta(i+1)
                HistNew=[HistNew 0];
            else
                last=HistNew(end);HistNew(end)=[];
                HistNew=[HistNew 0 last];
            end
    end
end

for i=1:length(HistNew)
   Ty(i,i)=HistNew(i); 
end