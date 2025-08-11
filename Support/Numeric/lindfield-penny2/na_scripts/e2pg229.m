%Solution of the Lorenz equations
global r
r=input('enter a value for the constant r');
simtime=input('enter runtime');
acc=input('enter accuracy value');
initx=[-7.69 -15.61 90.39]';
tspan=[0 simtime];
options=odeset('RelTol',acc);
%Call ode45 to solve equations
[t x]=ode45('f505',tspan,initx,options);
%Plot results against time
figure(1); plot(t,x);
xlabel('time'); ylabel('x');
figure(2); plot(x(:,1),x(:,3));
xlabel('x'); ylabel('z');