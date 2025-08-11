h=0.5;i=1;
disp('     h     1st deriv  2nd deriv  3rd deriv  4th deriv');
while h>=1e-5
  t1=h; t2=diffgen('f402', 1, 1, h);
  t3=diffgen('f402', 2, 1, h); t4=diffgen('f402', 3, 1, h);
  t5=diffgen('f402', 4, 1, h);
  fprintf('\n%10.5f%10.5f%10.5f%11.5f%12.5f',t1,t2,t3,t4,t5);
  h=h/10; i=i+1;
end
fprintf('\n')