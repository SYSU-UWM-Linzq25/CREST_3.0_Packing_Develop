function [lam,u]=eigit(A,tol)
% Solves EVP to determine dominant eigenvalue and associated vector
%
% Sample call: [lam,u]=eigit(A,tol)
% A is a square matrix, tol is the accuracy
% lam is the dominant eigenvalue, u is the associated vector
%
[n,n]=size(A);
err=100*tol;
u0=ones(n,1);
iter=0;
while err>tol
  v=A*u0;
  u1=(1/max(v))*v;
  err=max(abs(u1-u0));
  u0=u1; iter=iter+1;
end
u=u0; iter
lam=max(v);