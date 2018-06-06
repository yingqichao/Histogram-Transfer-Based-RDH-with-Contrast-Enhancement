function [Qxy,Qyx]=nonCrossEdge(Px,Py)

m = length(Px);
CPx = zeros(m+1,1);
for i=1:m
    CPx(i+1)=CPx(i)+Px(i);
end

n = length(Py);
CPy = zeros(n+1,1);
for i=1:n
    CPy(i+1)=CPy(i)+Py(i);
end

Qxy = zeros(m,n);
Qyx = zeros(m,n);
for x=0:(m-1)
    for y=0:(n-1)
        jval = max(0,min(CPx(x+2),CPy(y+2))-max(CPx(x+1),CPy(y+1)));

        Qxy(x+1,y+1)= jval/(Px(x+1)+eps);
        Qyx(x+1,y+1)= jval/(Py(y+1)+eps);
    end
end
Qyx=Qyx';

end