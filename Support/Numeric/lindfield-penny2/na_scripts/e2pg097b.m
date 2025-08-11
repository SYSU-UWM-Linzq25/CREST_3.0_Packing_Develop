%generate a sparse matrix
offdiag=sparse(2:100,1:99,2*ones(1,99),100,100);
offdiag2=sparse(4:100,1:97,3*ones(1,97),100,100);
offdiag3=sparse(95:100,1:6,7*ones(1,6),100,100);
a=sparse(1:100,1:100,4*ones(1,100),100,100);
a=a+offdiag+offdiag'+offdiag2+offdiag2'+offdiag3+offdiag3';
a=a*a';a1=flipud(a);a =a+a1;
%generate full matrix
b=full(a); morder=symmmd(a);
%time & flops
flops(0);
lud=lu(a(morder,morder)); flsp=flops; flops(0);
fullu=lu(b); flful=flops;
subplot(2,2,1), spy(a);title('Original matrix');
subplot(2,2,2), spy(a(morder,morder));title('Ordered Matrix')
subplot(2,2,3), spy(fullu);title('LU decomposition,unordered matrix');
subplot(2,2,4), spy(lud);title('LU decomposition, ordered matrix');
fprintf('flops sparse lu = %6.0f\n',flsp)
fprintf('flops full lu = %8.0f\n',flful)