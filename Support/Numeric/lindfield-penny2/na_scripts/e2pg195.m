disp('   n  Simpson value    Gauss value');
n=2; j=1;
while n<=16
  in1 = simp2v('f412',1,2,0,1,n);
  in2 = gauss2v('f412',1,2,0,1,n);
  fprintf('%4.0f%17.8e%17.8e\n',n,in1,in2);
  n=2*n;j=j+1;
end;