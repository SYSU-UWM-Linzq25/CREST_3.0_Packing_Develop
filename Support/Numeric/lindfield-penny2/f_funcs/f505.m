function fv=f505(t,x)
%x, y and z are represented by x(1), x(2) and x(3)
global r
fv=zeros(3,1); fv(1)=10*(x(2)-x(1));
fv(2)=r*x(1)-x(2)-x(1)*x(3); fv(3)=x(1)*x(2)-8*x(3)/3;