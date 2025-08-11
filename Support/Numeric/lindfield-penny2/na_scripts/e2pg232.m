% x(1) is the hare population and x(2) the lynx population
simtime=input('enter runtime');
acc=input('enter accuracy value');
%Initialise values of populations
initx=[5000 100]';
options=odeset('RelTol',acc);
[t x]=ode23('f506',[0 simtime],initx,options);
plot(t,x);
xlabel('time'); ylabel('population');