function [f,a]=golden(func,p,tol)
% Golden search for finding min of one variable non-linear function.
%
% Example call: [f,a]=golden(func,p,tol)
% func is the name of the user defined non-linear function.
% p is a 2 element vector giving the search range.
% tol is the tolerance. a is the optimum values of x.
% a is the values of the independent variable which gives the min of
% func. f is the minimum of the function.
%
if p(1)<p(2)
  a=p(1); b=p(2);
else
  a=p(2); b=p(1);
end
g=(-1+sqrt(5))/2;
r=b-a;
iter=0;
while r>tol
  x=[a+(1-g)*r a+g*r];
  y=feval(func,x);
  if y(1)<y(2)
    b=x(2);
  else
    a=x(1);
  end
  r=b-a; iter=iter+1;
end
iter
f=feval(func,a);