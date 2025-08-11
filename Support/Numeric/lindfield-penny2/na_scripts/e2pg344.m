c=[-2 -1 -4 0 0];
a=[1 1 1 1 0;1 2 3 0 1 ]; b=[7 12]';
[xsol,ind]=barnes(a,b,c,.00005);
i=1;fprintf('\nSolution is:');
for j=ind
  fprintf('\nx(%1.0f)=%8.4f\',j,xsol(i));
  i=i+1;
end;
fprintf('\nOther variables are zero\n')