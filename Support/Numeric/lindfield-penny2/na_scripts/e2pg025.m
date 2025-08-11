clf
[x,y]=meshgrid(-4.0:0.2:4.0,-4.0:0.2:4.0);
z=0.5*(-20*x.^2+x)+0.5*(-15*y.^2+5*y);
figure(1);
surfl(x,y,z);
axis([-4 4 -4 4 -400 0] )
xlabel('x-axis'); ylabel('y-axis'); zlabel('z-axis');
figure(2);
contour3(x,y,z,15);
axis([-4 4 -4 4 -400 0] )
xlabel('x-axis'); ylabel('y-axis'); zlabel('z-axis');
figure(3)
contourf(x,y,z,10)
xlabel('x-axis'); ylabel('y-axis');