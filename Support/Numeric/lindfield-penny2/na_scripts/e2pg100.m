%generate a sparse triple diagonal matrix
rowpos=2:100; colpos=1:99;
values=ones(1,99);
offdiag=sparse(rowpos,colpos,values,100,100);
a=sparse(1:100,1:100,4*ones(1,100),100,100);
a=a+offdiag+offdiag';
%Now generate a sparse least squares system
als=a(:,1:50);
%generate full matrix
cfl=full(als);
rhs=1:100;
flops(0); x=als\rhs'; f1=flops;
flops(0); x=cfl\rhs'; f2=flops;
fprintf('flops sparse least squares solve = %6.0f\n',f1);
fprintf('flops full least squares solve = %8.0f\n',f2);