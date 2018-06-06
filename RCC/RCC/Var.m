function rst=Var(u,l,d,r)
s=zeros(1,4);
s(1)=abs(d-l);s(2)=abs(l-u);
s(3)=abs(u-r);s(4)=abs(r-d);
rst=var(s,1);
end