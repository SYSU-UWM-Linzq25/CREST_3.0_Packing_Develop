% Hilbert matrix test.
disp('    n       cond             rcond      log10(cond)')
for n= 4:15
  a=hilb(n);
  fprintf('%5.0f%16.4e',n,cond(a));
  fprintf('%16.4e%10.2f\n',rcond(a),log10(cond(a)));
end