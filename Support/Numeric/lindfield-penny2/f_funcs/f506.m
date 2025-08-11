function fv=f506(t,x)
fv=zeros(2,1);
fv(1)=2*x(1)-0.001*x(1)*x(2);
fv(2)=-10*x(2)+0.002*x(1)*x(2);