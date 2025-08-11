n=2; i=1;
tic; flops(0)
disp(' n integral value');
while n<512
  h=1/n; x=0:h:1; f=f402(x);
  trapval=h*trapz(f);
  fprintf('%3.0f%14.9f\n',n,trapval);
  n=2*n; i=i+1;
end
t=toc;
fprintf('\ntime= %4.2f secs flops=%6.0f\n',t,flops);