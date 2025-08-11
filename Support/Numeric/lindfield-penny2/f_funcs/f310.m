function q=f310(p)
x=p(1); y=p(2); z=p(3);
q=zeros(3,1);
q(1)=sin(x)+y*y+log(z)-7;
q(2)=x*3+2^y-z^3+1;
q(3)=x+y+z-5;