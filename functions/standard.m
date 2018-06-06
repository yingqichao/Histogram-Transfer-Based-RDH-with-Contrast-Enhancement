%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Calculate similarity index.
%%% Inputs:I,W
%%% Outputs:RCE,REE,RMBE,RSS
%%% 2017.10.1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function std=standard(I)
std=0;[row,col]=size(I);I=double(I);
Mean=sum(sum(I))/row/col;
for i=1:row
    for j=1:col
        std=std+(I(i,j)-Mean)^2;
    end
end
std=sqrt(std/row/col);