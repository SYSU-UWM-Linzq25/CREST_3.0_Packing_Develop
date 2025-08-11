offdiag=sparse(2:100,1:99,2*ones(1,99),100,100);
a=sparse(1:100,1:100,4*ones(1,100),100,100);
a=a+offdiag+offdiag';
%generate full matrix
b=full(a);
%generate arbitrary right hand side for system of equations
rhs=[1:100]';
flops(0); lu1=lu(a); f1=flops;
flops(0); lu2=lu(b); f2=flops;
fprintf('flops for sparse LU = %6.0f\n',f1);
fprintf('flops for full LU = %8.0f\n',f2);