%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Calculate one row's H(Y|X).To calculate H(X|Y) use T'
%%% Inouts:T(transfer matrix),row(row or column number)
%%% Outputs:Entrophy(H(Y|X))
%%% 2017.10.1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Entrophy=cross_entropy(T,row)
Sum_row=sum(T,2);Entrophy=0;
if Sum_row(row)==0
    return;
else
    for k=1:256
               Trow=T(row,k)/Sum_row(row);
            if Trow~=0
              Entrophy=Entrophy-Sum_row(row)*Trow*log2(Trow);
            end
    end
end