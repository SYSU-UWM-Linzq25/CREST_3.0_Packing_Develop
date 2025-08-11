x=0:.2:2; C=1+x.^2; D=x; E=-ones(1,11); F=x.^2;
flag1=1; p1=1; flag2=1; p2=2;
z=twopoint(x,C,D,E,F,flag1,flag2,p1,p2);
B=1/3; A=-sqrt(5)*B/2;
xx=0:.01:2;
zz=A*xx+B*sqrt(1+xx.^2)+B*(2+xx.^2);
plot(x,z,'o',xx,zz)
xlabel('x'); ylabel('z')