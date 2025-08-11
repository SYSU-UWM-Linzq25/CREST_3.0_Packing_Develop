function w=f412(x,z)
[n1,n2]=size(x); [m1,m2]=size(z);
if (n1==1)&(m1==1)
  [xx,zz]=meshgrid(x,z);
  x2=xx.^2;x4=xx.^4; xd=x4-x2;
  w=x2.*(xd.*zz+x2).*xd;
else
  disp('x and z must be scalars or row vectors'); break
end