%simultaneous first order differential equations
%These would be dx/dt =y, Dy = 3*t - 4*x.
%Using dsolve this would become
sol=dsolve('Dx=y','Dy = 3*t-4*x','x(0)=0','y(0)=1');
sol.x, sol.y
%We now plot the symbolic solution
%to the differential equation
t=0:.01:5;
plot(t,3/4*t+1/8*sin(2*t));
xlabel('t');ylabel('x');
title('Plot of the symbolic and Numeric solution of the same differential equation');
hold on
options=odeset('reltol', 1e-5,'abstol',1e-5);
tspan=[0 5]; initx=[0 1];
[t,x]=ode45('f901',tspan,initx,options);
plot(t,x(:,1),'g+');
gtext('The + symbol indicates the numerical solution')