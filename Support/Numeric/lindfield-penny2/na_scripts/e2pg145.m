c=[-3 -10 10 44 48];
[rts, it]=bairstow(c,5,0.00005);
for i=1:5
  fprintf('\nroot%3.0f Real part=%7.4f',i,rts(i,1));
  fprintf(' Imag part=%7.4f\n',rts(i,2));
end;