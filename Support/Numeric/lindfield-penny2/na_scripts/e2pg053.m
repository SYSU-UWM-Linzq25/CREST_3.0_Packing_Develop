disp('n       fflop    fflop/n^3   triflop   triflop/n^2');
a=[ ];
for n=10:10:50
  a=100*rand(n); b=[1:n]';
  flops(0)
  x=a\b;
  f1=flops;
  f1d=f1/n^3;
  for i=1:n
    for j=i+1:n
      a(i,j)=0;
    end
  end
  flops(0)
  x=a\b;
  f2=flops;
  f2d=f2/n^2;
  fprintf('%2.0f%11.0f%9.2f%11.0f%11.2f\n',n,f1,f1d,f2,f2d)
end;