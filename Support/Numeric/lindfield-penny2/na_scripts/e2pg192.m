disp(' n     integral value     flops/n^2');
n=4; j=1;
while n<=256
  flops(0); int=simp2v('f411',0,10,0,10,n); fl=flops;
  fprintf('%4.0f%17.8e%12.2f\n',n,int,fl/n^2);
  n=2*n; j=j+1;
end