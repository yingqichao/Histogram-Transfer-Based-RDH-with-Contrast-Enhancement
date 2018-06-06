function [ Py,Dav,exitfg,iters] = minDistortionEmr(Px,Dxy,Hy)
%   Miniminze average distortion between stego-signal and cover-signal
%
%   Input:  
%               Px  : cover-signal probability distribution
%               Dxy : square error distortion matrix
%               Hy  : expected stego-signal entropy
%
%   Output:
%               Py      : stego-signal probability distribution
%               Dav     : corresponding minimized distortion value
%               exitfg  : exit flag: 0-->success   -1-->invalid input  1-->failed
%               iters   : number of iterations
%%********************************************************************
%
%   author:     Xiaocheng Hu
%   college:    University of Science and Technology of China
%   date:       9/2/2012
%
%%*********************************************************************

[m,n]   = size(Dxy);

% input validation
%
if ( abs(sum(Px)-1.0) > 1e-8 ) || (Hy > log(n)) || (Hy < -sum(Px.*log(Px)))
    Pxy=zeros(m,n);Dav=0;exitfg=-1;
    disp('minDistortionEmr invalid input!');
    return;
end
%}

%
MPx     = Px(:,ones(n,1));%repmat(Px,1,n);
Dxy     = MPx.*Dxy;

%parameters
MAXITERS    = 300;
Tol         = 1e-8;
NTTol       = 1e-8;
MU          = 20;
Alpha       = 0.01;
Beta        = 0.6;

% initialize x0
x           = zeros(n+m+1,1);%+1.0;
x(1:n)      = log(1/n)+1.0;
x(n+1:n+m)  = abs(x(1))+0.01;
x(n+m+1)    = 1.0;

% initialize t0 with least square
Mfx         = Dxy+repmat(x(n+1:n+m),1,n)+Px*(x(1:n)');
fx          = [Mfx(:);x(n+m+1)];
lA          = [exp(x(1:n)/x(n+m+1)-1);ones(m,1);sum(exp(x(1:n)/x(n+m+1)-1).*(x(n+m+1)-x(1:n)))/x(n+m+1)-Hy];
lb          = [(sum(MPx./Mfx))';sum(1./Mfx,2);1/x(n+m+1)];
t           = (lA'*lb)/(lA'*lA);
t           = ceil(t);
%t=1;

%
for iters=1:MAXITERS
    % calculate function value and it's gratitude
    val=t*(x(n+m+1)*sum(exp(x(1:n)/x(n+m+1)-1))+sum(x(n+1:n+m))-Hy*x(n+m+1))-sum(log(fx));
    grad=t*([exp(x(1:n)/x(n+m+1)-1);ones(m,1);sum(exp(x(1:n)/x(n+m+1)-1).*(x(n+m+1)-x(1:n)))/x(n+m+1)-Hy])-[(sum(MPx./Mfx))';sum(1./Mfx,2);1/x(n+m+1)];
    
    
    %{
    Hf0=[diag(exp(x(1:n)/x(n+m+1)-1)/x(n+m+1)),zeros(n,m),-exp(x(1:n)/x(n+m+1)-1).*x(1:n)/(x(n+m+1)^2); ...
         zeros(m,m+n+1); ...
         -(exp(x(1:n)/x(n+m+1)-1).*x(1:n)/(x(n+m+1)^2))',zeros(1,m),sum(exp(x(1:n)/x(n+m+1)-1).*(x(1:n).^2))/(x(n+m+1)^3)];
    Hfx=[-diag(sum((MPx./Mfx).^2))  , -(MPx./(Mfx.^2))',            zeros(n,1); ...
         -(MPx./(Mfx.^2))           , -diag(sum(1./(Mfx.^2),2)),    zeros(m,1);         ...
         zeros(1,n)                 , zeros(1,m)               ,    -1/(x(n+m+1)^2)];         
    hess=t*Hf0-Hfx;
    Dx=-hess\grad;
    %}
    % Calculate Newton step, fast
    Dx=fast_linear_solver(t*exp(x(1:n)/x(n+m+1)-1)/x(n+m+1)+(sum((MPx./Mfx).^2))', ...
                          t*[zeros(n,m),-exp(x(1:n)/x(n+m+1)-1).*x(1:n)/(x(n+m+1)^2)]+[(MPx./(Mfx.^2))',zeros(n,1)], ...
                          t*[zeros(m,m),zeros(m,1);zeros(1,m),sum(exp(x(1:n)/x(n+m+1)-1).*(x(1:n).^2))/(x(n+m+1)^3)]+[diag(sum(1./(Mfx.^2),2)),zeros(m,1);zeros(1,m),1/(x(n+m+1)^2)], ...
                          -grad);
    fprime=grad'*Dx;
    
    % Solved Centering step and update t
    if( (-fprime < NTTol))
        gap=(m*n+1)/t;
        
        % stopping criterion
        if( gap < Tol ),break;end;
        
        % update t and continue the next Centering step
        t=MU*t;
        continue;      
    end
    
    % Backtracking step 1, ensure the domain of fx
    step=1;
    DMf=repmat(Dx(n+1:n+m),1,n)+Px*(Dx(1:n)');Dff=[DMf(:);Dx(n+m+1)];
    while any((fx+step*Dff)<=0)
        step=Beta*step;
    end
    
    newx    = x+step*Dx;
    newfx   = fx+step*Dff;
    % Backtracking step 2, decrease fx sufficiently
    %
    while ( (t*(newx(n+m+1)*sum(exp(newx(1:n)/newx(n+m+1)-1))+sum(newx(n+1:n+m))-Hy*newx(n+m+1))-sum(log(newfx))) > (val+Alpha*step*fprime) )
        step=Beta*step;
        newx=x+step*Dx;
        newfx=fx+step*Dff;
    end  
    %}
   
    % update variables
    x   = newx;
    fx  = newfx;
    Mfx = Mfx+step*DMf;
    
    
end

% Output
Py  = exp(x(1:n)/x(n+m+1)-1);
Dav = -(x(n+m+1)*sum(exp(x(1:n)/x(n+m+1)-1))+sum(x(n+1:n+m))-Hy*x(n+m+1));

% check if success 
if( abs(sum(Py)-1.0) < 1e-8 )
    exitfg=0;
else
    exitfg=1;
end
fprintf('minDistortionEmr Iters: %d\t Distortion: %f\t Sum of Py: %f\n',iters,Dav,sum(Py));

%% Block elimination method to solve linear equations
function [sx]=fast_linear_solver(A11,A12,A22,b)
    [sn,sm]=size(A12);
    b1=b(1:sn);
    b2=b(sn+1:sn+sm);
    
    invA11=1./A11;
    Tm=repmat(invA11',sm,1).*(A12');
    S=A22-Tm*A12;
    bs=b2-Tm*b1;
    % check if S is positive definite
    %
    [L,p]=chol(S,'lower');
    if (p > 0)
        sx=zeros(sn+sm,1);
        return;
    end
    
    zz=L\bs;
    x2=L'\zz;
    %}
    %topts.SYM=true;topts.POSDEF=true;
    %[x2,Rf]=linsolve(S,bs,topts);  
    %x2=S\bs;
    x1=invA11.*(b1-A12*x2);
    sx=[x1;x2];
end

end

