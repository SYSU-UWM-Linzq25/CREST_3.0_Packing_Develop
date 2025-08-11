% Solving Zeeman’s Catastrophe model of the heart
global p
p=input('enter tension value');
simtime=input('enter runtime');
acc=input('enter accuracy value');
options=odeset('RelTol',acc);
initx=[0 -1]';
[t x]=ode23('f504',[0 simtime],initx,options);
%Plot results against time
plot(t,x(:,1),'--',t,x(:,2),'-');
xlabel('time'); ylabel('x and s');