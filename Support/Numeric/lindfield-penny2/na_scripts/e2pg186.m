n=4;
disp('   n   Simpsons value   Filons value');
while n<=2048
  int1=filon('f407',1,100,0,2*pi,n);
  int2=simp1('f407a',0,2*pi,n);
  fprintf('%4.0f%17.8e%17.8e\n',n,int2,int1);
  n=2*n;
end