a=[5 4 1 1;4 5 1 1; 1 1 4 2;1 1 2 4];
h1=hess(a);
for i=1:10
  [q r]=qr(h1);
  h2=r*q;
  h1=h2;
  p=diag(h1)';
  fprintf('%2.0f%8.4f%8.4f',i,p(1),p(2));
  fprintf('%8.4f%8.4f\n',p(3),p(4));
end