disp(' n      posfl   posfl/n^3  rflops   rflop/n^3   cr/1000');
for n=10:2:20
  a=[ ];
  a=pascal(n); cd1=cond(a); b=[1:n]';
  flops(0)
  x=a\b;
  f1=flops;
  f1d=f1/n^3;
  a=a+rand(size(a)); cd2=cond(a); cr=cd1/cd2/1000;
  flops(0);
  x=a\b;
  f2=flops;
  f2d=f2/n^3;
  fprintf('%2.0f%10.0f%9.2f%11.0f%9.2f%12.0f\n',n,f1,f1d,f2,f2d,cr)
end