n=2; i=1;
t=clock; flops(0)
disp(' n integral value');
while n<512
  simpval=simp1('f402',0,1,n); % or simpval=simp2(etc.);
  fprintf('%3.0f%14.9f\n',n,simpval);
  n=2*n;i=i+1;
end
fprintf('\ntime= %4.2f secs flops=%6.0f\n',etime(clock,t),flops);