%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Assume secret information bits are hidden randomly with the matrix
%%% Inouts:T(transfer matrix),I(original image),quan(If the matrix is quantized in advance)
%%% Outputs:X(Embedded image.
%%% 2017.10.1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [X]=outlook(T,I,quan)
X=I;
for i=1:256
    [r,c]=find(I==i-1);len=length(r);
    if sum(T(i,:),2)==0
        continue;
    else
        index=ones(len,1)*i;start=1;
        for j=1:256
          if T(i,j)>0
              index(start:round(start-1+T(i,j)*quan))=j;
              start=round(start+T(i,j)*quan);
          end
        end
        for k=1:len
           X(r(k),c(k))=index(k)-1;
        end
    end
end
