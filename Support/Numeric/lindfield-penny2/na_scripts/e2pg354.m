clf
[x,y]=meshgrid(-4.0:0.2:4.0,-4.0:0.2:4.0);
z=0.5*(x.^4-16*x.^2+5*x)+0.5*(y.^4-16*y.^2+5*y);
figure(1)
surfl(x,y,z);
axis([-4 4 -4 4 -80 20])
xlabel('x1'); ylabel('x2'); zlabel('z');
x1=[1 2.8121 -2.8167 -2.9047 -2.9035];
y1=[0.5 -2.0304 -2.0295 -2.9080 -2.9035];
figure(2)
contour(-4.0:0.2:4.0,-4.0:0.2:4.0,z,15);
xlabel('x1'); ylabel('x2');
hold on
plot(x1,y1,x1,y1,'o')
xlabel('x1');ylabel('x2');
hold off