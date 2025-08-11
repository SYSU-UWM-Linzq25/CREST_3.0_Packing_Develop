load testdata
Xd=[sin(1./(xs+0.2)); xs; us];
al=zeros(2,15); al=['sin(1/(x+0.2)):';'coeff x       :'];
b=mregg(Xd,0,0,al);
xx=0:.05:5;
yy=b(1)*sin(1./(xx+0.2))+b(2)*xx;
plot(xs,us,'o',xx,yy,'k')
axis([0 5 -1.5 1.5])
xlabel('x'); ylabel('y');