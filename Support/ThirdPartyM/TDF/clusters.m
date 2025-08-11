function z=clusters(x,threshold)
k=1;
for i=1:length(x)
    if (x(i)>threshold)
        z(k,1)=i;
        z(k,2)=x(i);
        k=k+1;
    end;
end;