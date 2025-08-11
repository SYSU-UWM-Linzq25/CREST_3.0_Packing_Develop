n=100; b=1:n;
disp('   density      flops_sparse   flops_full');
for density=0.01:0.01:0.1
  A=sprandsym(n,density)+0.1*speye(n);
  density=density+1/n;
  flops(0); x=A\b'; f1=flops;
  B=full(A);
  flops(0); y=B\b'; f2=flops;
  fprintf('%10.3f%14.0f%14.0f\n',density,f1,f2);
end