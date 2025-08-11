x=1:.2:2;
y=ones(size(x))./x;
p=polyfit(x,y,5)
interpval=polyval(p,1.03);
fprintf('interpolated value= %10.8f\n',interpval);