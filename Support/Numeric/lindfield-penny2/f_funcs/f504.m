function fv=f504(t,x)
%note that x and s are represented by x(1) and x(2)
global p
fv=zeros(2,1);
fv(1) = 0.5*(-x(2)-x(1)^3/3+p*x(1));
fv(2)=2*x(1);