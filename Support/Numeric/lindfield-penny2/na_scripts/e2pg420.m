%Script for running newtonmvsym
global f
syms a b
x=sym([a b]);
f=[x(1)*x(2)-2,x(1)^2+x(2)^2-4];
[x1,fr,it]=newtmvsym([1 0],f,2,.000000005)