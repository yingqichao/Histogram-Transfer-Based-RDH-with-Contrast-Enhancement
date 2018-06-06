%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Calculate H(X).
%%% Inouts:H(1D Histogram of an image)
%%% Outputs:EntrophyX
%%% 2017.10.1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EntrophyX=H_of_X(H)
EntrophyX=cross_entropy(H',1);

