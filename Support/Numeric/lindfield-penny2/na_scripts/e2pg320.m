load testdata
xx=0:.05:5;
p=polyfit(xs,us,3), yy=polyval(p,xx);
Xd=[xs; xs.^2; xs.^3; us];
al=zeros(3,15); al=['coeff x       :';'coeff x^2     :';'coeff x^3     :'];
b=mregg(Xd,1,0,al);
b=mregg(Xd,0,0,al);
plot(xs,us,'o',xx,yy)
hold on
axis([0 5 -2 2])
p=polyfit(xs,us,5), yy=polyval(p,xx);
Xd=[xs; xs.^2; xs.^3; xs.^4; xs.^5; us];
al=zeros(5,15); al=['coeff x       :';'coeff x^2     :';'coeff x^3     :';'coeff x^4     :';'coeff x^5     :'];
b=mregg(Xd,1,0,al);
plot(xx,yy)
xlabel('x'); ylabel('y')
hold off