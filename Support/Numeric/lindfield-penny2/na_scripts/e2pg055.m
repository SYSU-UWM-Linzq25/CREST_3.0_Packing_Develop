disp(' n    op flops   op acc    invflops   invacc');
for n=4:2:14
  a=hilb(n); b=[1:n]';
  flops(0)
  x=a\b;
  f1=flops;
  nm1=norm(b-a*x);
  flops(0)
  x=inv(a)*b;
  f2=flops;
  nm2=norm(b-a*x);
  fprintf('%2.0f%10.2f%12.2e%10.2f%12.2e\n',n,f1,nm1,f2,nm2)
end