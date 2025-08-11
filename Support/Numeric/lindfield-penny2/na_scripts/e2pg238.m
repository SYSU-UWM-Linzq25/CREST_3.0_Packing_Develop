global a
b=[3 20 100 500 1000]; c=[2 .1 1 1 1]; tspan=[0 2];
options=odeset('reltol',1e-5,'abstol',1e-5);
for i=1:5
  a=[-b(i) -c(i);1 0];
  lambda=eig(a);
  eigenratio(i)=max(abs(lambda))/min(abs(lambda));
  time0=clock;
  inity=[0 1]';
  [t,y]=ode23('f508',tspan,inity,options);
  et(i)=etime(clock,time0);
end;
eigenratio
et