%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Calculate H(Y|X) and H(X|Y) of a given T.
%%% Inouts:T(transfer matrix)
%%% Outputs:EntrophyX(H(Y|X)),EntrophyY(H(X|Y))
%%% 2017.10.1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [EntrophyX,EntrophyY]=entropy(T)
Sum_row=sum(T,2);Sum_col=sum(T);EntrophyY=0;EntrophyX=0;
Trows=zeros(256,256);Tcols=zeros(256,256);
for i=1:256
    if Sum_row(i)~=0
       for j=1:256
           Trows(i,j)=T(i,j)/Sum_row(i);
           if Trows(i,j)~=0
            EntrophyX=EntrophyX-Sum_row(i)*Trows(i,j)*log2(Trows(i,j));
           end
       end
    end
end
for j=1:256
    if Sum_col(j)~=0
       for i=1:256
           Tcols(i,j)=T(i,j)/Sum_col(j);
           if Tcols(i,j)~=0
            EntrophyY=EntrophyY-Sum_col(j)*Tcols(i,j)*log2(Tcols(i,j));
           end
       end
    end
end