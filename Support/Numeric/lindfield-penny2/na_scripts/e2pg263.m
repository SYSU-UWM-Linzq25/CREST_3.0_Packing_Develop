x=1:.01:exp(1);
% compute eigenfunction values scaled to 1 or -1.
z0=sin((1*pi/2)*log(abs(x)));
z1=sin((3*pi/2)*log(abs(x)));
% plot eigenfuctions
plot(x,z0,x,z1)
hold on
% Discrete approximations to eigenfunctions
% Scaled to 1 or -1.
u0=(1/.5860)*[0.3119 0.4854 0.5690 0.5860];
u1=-(1/.6003)*[-0.6569 -0.0900 0.4473 0.6003];
% determine x values for plotting
r=(exp(1)-1)/4;
xx=[1+r 1+2*r 1+3*r 1+4*r];
plot(xx,u0,'*',xx,u1,'o')
hold off
axis([1 exp(1) -1.2 1.2])
xlabel('x')
ylabel('z')