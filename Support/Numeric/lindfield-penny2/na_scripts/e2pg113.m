disp('     real1    realsym1   real2    realsym2  comp1     comp2')
for n= 10:10:50
  a=rand(n);c=rand(n);s=a+c*i;t=rand(n)+i*rand(n);
  flops(0); [u,v]=eig(a); f1=flops/1e4;
  b=a+a'; d=c+c';
  flops(0); [u,v]=eig(b); f2=flops/1e4;
  flops(0); [u,v]=eig(a,c); f3=flops/1e4;
  flops(0); [u,v]=eig(b,d); f4=flops/1e4;
  flops(0); [u,v]=eig(s); f5=flops/1e4;
  flops(0); [u,v]=eig(s,t); f6=flops/1e4;
  fprintf('%8.0f%10.0f%10.0f%10.0f%10.0f%10.0f\n',f1,f2,f3,f4,f5,f6);
end;