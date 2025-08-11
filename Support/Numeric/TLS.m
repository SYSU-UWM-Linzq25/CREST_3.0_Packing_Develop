function [x,errA,errb]=TLS(A,b,n1,tol)
%% Mixed Total Least Squared Method
% optimally solves overdetermined linear equation-set 
% $Ax \approx b$
% in case both A and b contains erroneous columns.
%
% A could have exact columns
%% input parameters
% A: the coefficient matrix of m by n
% b: the right hand side of m by 1
% n1: the amount of first exact columns of A
%% ouput parameters
% x: unknowns
% errA: the error of the erroneous columns
% errB: the error of the right hand side column
%% QR factorization
if nargin<4
    tol=1e-1;
end
m=size(A);
n=size(A,2);
m1=length(b);
if m ~= m1
   error('the rows of A must equal to those of b.');  
end
if n1<0
    error('wrong n1');
elseif n1==0
    disp('no exact columns exist, using basic TSL mode');
    R22=[A,b];
else
    A1=A(:,1:n1);
    A2=A(:,n1+1:end);
    [Q,R]=qr(A1);
    R11=R(1:n1,:);
    R2=Q'*[A2,b];
    R12=R2(1:n1,:);
    R22=R2(n1+1:end,:);
end
n2=size(A,2)-n1;
% R=Q'*[A,b];
% R11=R(1:n1,1:n1);

%% Solving the equation
%% $R_{22}[x(n1+1:end);-1]=0$
% R22=R(n1+1:end,n1+1:end);
[U,S,V]=svd(R22);
vs=diag(S);
vs(end+1)=0;
indIgnorable=find(vs/(vs(1))<tol);
if indIgnorable-1<n2
    error('rank insufficient,solution is not unique');
elseif indIgnorable-1>n2
    disp('solution is not obtained within the tollerance');
end
x2=V(:,end);

if n1==0
    x=-x2/x2(end);
else
    opts.UT = true;
    x1=linsolve(R11,-R12*x2,opts);
    x=[x1;x2];
    x=-x/x(end);
end
x=x(1:end-1);
err=vs(end-1)*U(:,n2+1)*V(:,end)';
if n1>0
    err=Q*[zeros(n1,n-n1+1);err];
end
errA=err(:,1:end-1);
errb=err(:,end);
end