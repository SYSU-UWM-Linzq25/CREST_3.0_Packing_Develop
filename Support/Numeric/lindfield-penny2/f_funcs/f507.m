function neurf=f507(t,x)
global n sc
%Calculate synaptic current
I=2 .^[0:n-1]*sc-0.5*2 .^(2 .*[0:n-1]);
%Perform sigmoid transformation
V=(tanh(x/0.02)+1)/2;
%Compute interconnection values
p=2 .^[0:n-1].*V';
%Calculate change for each neuron
neurf=-x-2.^[0:n-1]'*sum(p)+I'+2.^(2.*[0:n-1])'.*V;