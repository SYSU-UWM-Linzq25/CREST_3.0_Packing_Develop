function [tvals, yvals]=feuler(f,tspan, startval,step)
% Euler's method for solving
% first order differential equation dy/dt = f(t,y).
%
% Example call: [tvals, yvals]=feuler(f,tspan,startval,step)
% The initial and final values of t are given by tspan=[start finish].
% Initial value of y is given by startval and step size by step.
% The function f(t,y) must be defined by the user.
%
steps=(tspan(2)-tspan(1))/step+1;
y=startval;t=tspan(1);
yvals=startval;tvals=tspan(1);
for i=2:steps
  y1=y+step*feval(f,t,y); t1=t+step;
  %collect values together for output
  tvals=[tvals, t1]; yvals=[yvals, y1];
  t=t1;y=y1;
end