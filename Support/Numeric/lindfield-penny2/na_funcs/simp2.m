function q = simp2(func,a,b,m)
% Implements Simpson's rule using for loop.
%
% Example call: q = simp2(func,a,b,m)
% Integrates user defined function
% func from a to b, using m divisions
%
if (m/2)~=floor(m/2)
  disp('m must be even'); break
end
h=(b-a)/m; s=0;
yl=feval(func,a);
for j=2:2:m
  x=a+(j-1)*h; ym=feval(func,x);
  x=a+j*h; yh=feval(func,x);
  s=s+yl+4*ym+yh;
  yl=yh;
end
q=s*h/3;