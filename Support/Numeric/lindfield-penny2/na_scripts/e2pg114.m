%generate a sparse triple diagonal matrix
rowpos=2:100;colpos=1:99;
values=ones(1,99);
offdiag=sparse(rowpos,colpos,values,100,100);
a=sparse(1:100,1:100,4*ones(1,100),100,100);
a=a+offdiag+offdiag';
%generate full matrix
b=full(a);
flops(0); eig(a); f1=flops;
flops(0); eig(b); f2=flops;
fprintf('time sparse eigen solve = %5.0f\n',f1);
fprintf('time full eigen solve = %6.0f\n',f2);