x=0:4; y=[3 1 0 2 4]; xx=0:.1:4;
yy=spline(x,y,xx);
plot(x,y,'o',xx,yy);
axis([0 4 -1 4]);
xlabel('x'); ylabel('y');