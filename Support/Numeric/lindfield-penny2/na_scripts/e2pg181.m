disp(' n   integral value');
for j=1:4
  n=2^j;
  int=gaherm('f405',n);
  fprintf('%3.0f%14.9f\n',n,int);
end