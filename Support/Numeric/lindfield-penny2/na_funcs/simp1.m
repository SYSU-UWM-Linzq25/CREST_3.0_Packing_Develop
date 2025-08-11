function q = simp1(func,a,b,m)
% Implements Simpson's rule using vectors.
%
% Example call: q = simp1(func,a,b,m)
% Integrates user defined function func from a to b, using m divisions
%
if (m/2)~=floor(m/2)
  disp('m must be even'); break
end
h=(b-a)/m;
x=[a:h:b]; y=feval(func,x);
v=2*ones(m+1,1);
v2=2*ones(m/2,1);
v(2:2:m)=v(2:2:m)+v2;
v(1)=1; v(m+1)=1;
q=y*v;
q=q*h/3;