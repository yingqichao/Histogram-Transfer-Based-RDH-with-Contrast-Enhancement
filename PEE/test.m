a=[1 2 3 4 5 6];
i=1;
while i<=length(a)
    if a(i)<3
        a(i)=[];
       i=i-1; 
    end
    i=i+1;
end