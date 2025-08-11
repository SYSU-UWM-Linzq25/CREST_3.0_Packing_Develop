%generate a sparse triple diagonal matrix
rowpos=2:100; colpos=1:99;
values=2*ones(1,99);
offdiag=sparse(rowpos,colpos,values,100,100);
a=sparse(1:100,1:100,4*ones(1,100),100,100);
a=a+offdiag+offdiag';
%generate full matrix
b=full(a);
%generate arbitrary right hand side for system of equations
rhs=[1:100]';
flops(0); x=a\rhs; f1=flops;
flops(0); x=b\rhs; f2=flops;
fprintf('flops for sparse matrix solve = %6.0f\n',f1);
fprintf('flops for full matrix solve = %8.0f\n',f2);