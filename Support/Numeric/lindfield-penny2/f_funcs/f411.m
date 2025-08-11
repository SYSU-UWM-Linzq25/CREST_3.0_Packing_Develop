function z=f411(x,y)
[n1,n2]=size(x); [m1,m2]=size(y);
if (n1==1)&(m1==1)
  [xx,yy]=meshgrid(x,y);
  z=yy.^2 .*sin(xx);
else
  disp('x and y must be scalars or row vectors'); break
end