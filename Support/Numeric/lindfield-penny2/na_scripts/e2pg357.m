n=10; tol=1e-8;
A=10*rand(n); b=10*rand(n,1);
ada=A*A';
% To ensure a symmetric positive definite matrix.
sol=solvercg(ada,b,n,tol);
disp('Solution of system is:');
disp(sol);
accuracy=norm(ada*sol-b);
fprintf('Norm of residuals =%12.9f\n',accuracy);