function ImgOut=move(ImgIn,Origin,Revise)
ImgOut=ImgIn;
[r,c]=find(ImgIn==Origin);
for i=1:length(r)
    ImgOut(r(i),c(i))=Revise;
end