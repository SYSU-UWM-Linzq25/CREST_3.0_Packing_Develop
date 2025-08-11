function [x1,x2]=rootquad(a,b,c)
% Solves ax^2+bx+c=0 given the coefficients a,b,c.
% The solutions are assigned to x1 and x2
%
d=b*b-4*a*c;
x1=(-b+sqrt(d))/(2*a);
x2=(-b-sqrt(d))/(2*a);