n=4;
disp('  n  Filon no switch  Filon with switch');
while n<=4096
  int1=filonmod('f406',2,1,1e-10,1,n);
  int2=filon('f406',2,1,1e-10,1,n);
  fprintf('%4.0f%17.8e%17.8e\n',n,int1,int2);
  n=2*n;
end