disp('n         op fl  op fl/n^3    cholflops  cholflop/n^3');
for n=10:2:20
  a=[ ];
  a=pascal(n);
  b=[1:n]';
  flops(0)
  x=a\b;
  f1=flops;
  f1d=f1/n^3;
  flops(0);
  r=chol(a);v=r'\b;
  x=r\b;
  f2=flops;
  f2d=f2/n^3;
  fprintf('%2.0f%12.0f%10.2f%14.0f%10.2f\n',n,f1,f1d,f2,f2d)
end