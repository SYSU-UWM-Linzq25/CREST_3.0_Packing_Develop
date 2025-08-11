% Hopfield and Tank neuron model for binary conversion problem
global n sc
n=input('enter number of neurons');
sc=input('enter number to be converted to binary form');
simtime=input('enter runtime');
acc=input('enter accuracy value');
initx=zeros(1,n)';
options=odeset('RelTol',acc);
%Call ode45 to solve equation
[t x]=ode45('f507',[0 simtime],initx,options);
plot(t,(tanh(x/.02)+1)/2);
xlabel('time'); ylabel('V');