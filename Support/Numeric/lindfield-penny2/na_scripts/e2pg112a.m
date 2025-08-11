i=sqrt(-1);
a=[10+2*i 1 2;1-3*i 2 -1;1 1 2];
b=[1 2-2*i -2;4 5 6;7+3*i 9 9];
[T,S,q,z,v]=qz(a,b);
r=diag(T)./diag(S)
eig(a,b)