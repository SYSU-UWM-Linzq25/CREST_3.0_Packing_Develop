disp(' n   integral value');
for j=1:3
  n=2^j;
  int=galag('f404',n);
  fprintf('%3.0f%14.9f\n',n,int);
end