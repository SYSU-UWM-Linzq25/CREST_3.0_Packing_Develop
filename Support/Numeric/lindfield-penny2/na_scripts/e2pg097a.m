%generate a sparse matrix
offdiag=sparse(2:100,1:99,2*ones(1,99),100,100);
offdiag2=sparse(4:100,1:97,3*ones(1,97),100,100);
offdiag3=sparse(95:100,1:6,7*ones(1,6),100,100);
a=sparse(1:100,1:100,4*ones(1,100),100,100);
a=a+offdiag+offdiag'+offdiag2+offdiag2'+offdiag3+offdiag3';
a=a*a';
%generate full matrix
b=full(a);
morder=symmmd(a);
%time & flops
flops(0);
spmult=a(morder,morder)*a(morder,morder)';
flsp=flops;
flops(0);
fulmult=b*b';
flful=flops;
fprintf('flops sparse mult =%6.0f\n',flsp);
fprintf('flops full mult = %6.0f\n',flful)