function LM=locationmap(ImgIn,ImgOut,i,j)
[r,c]=find(ImgOut==j);LM=[];
for k=1:length(r)
    if ImgIn(r(k),c(k))==i
        LM=[LM 1];
    else
        LM=[LM 0];
    end
end

