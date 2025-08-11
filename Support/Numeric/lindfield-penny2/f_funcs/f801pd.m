function pd=f801pd(x);
pd=zeros(size(x));
pd(1)=0.5*(4*x(1)^3-32*x(1)+5);
pd(2)=0.5*(4*x(2)^3-32*x(2)+5);