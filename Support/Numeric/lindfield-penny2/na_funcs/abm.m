function [tvals, yvals]=abm(f,tspan,startval,step)
% Adams Bashforth Moulton method for solving
% first order differential equation dy/dt = f(t,y).
%
% Example call: [tvals, yvals]=abm(f,tspan,startval,step)
% The initial and final values of t are given by tspan=[start finish].
% Initial y is given by startval and step size is given by step.
% The function f(t,y) must be defined by the user.
% For an example of this function definition, see page 160.
%
% 3 steps of Runge-Kutta are required so that ABM method can start.
% Set up matrices for Runge-Kutta methods
%
b=[ ];c=[ ];d=[ ]; order=4;
b=[ 1/6 1/3 1/3 1/6]; d=[0 .5 .5 1];
c=[0 0 0 0;0.5 0 0 0;0 .5 0 0;0 0 1 0];
steps=(tspan(2)-tspan(1))/step+1;
y=startval; t=tspan(1); fval(1)=feval(f,t,y);
ys(1)=startval; yvals=startval; tvals=tspan(1);
for j=2:4
  k(1)=step*feval(f,t,y);
  for i=2:order
    k(i)=step*feval(f,t+step*d(i),y+c(i,1:i-1)*k(1:i-1)');
  end;
  y1=y+b*k'; ys(j)=y1; t1=t+step;
  fval(j)=feval(f,t1,y1);
  %collect values together for output
  tvals=[tvals,t1]; yvals=[yvals,y1];
  t=t1; y=y1;
end;
%ABM now applied
for i=5:steps
  y1=ys(4)+step*(55*fval(4)-59*fval(3)+37*fval(2)-9*fval(1))/24;
  t1=t+step; fval(5)=feval(f,t1,y1);
  yc=ys(4)+step*(9*fval(5)+19*fval(4)-5*fval(3)+fval(2))/24;
  fval(5)=feval(f,t1,yc);
  fval(1:4)=fval(2:5);
  ys(4)=yc;
  tvals=[tvals,t1]; yvals=[yvals,yc];
  t=t1; y=y1;
end;
