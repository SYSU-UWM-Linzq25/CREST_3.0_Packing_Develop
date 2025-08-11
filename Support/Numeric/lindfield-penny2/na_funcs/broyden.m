function [xv,it]=broyden(x,f,n,tol,varargin)
% Broyden's method for solving a system of n non-linear equations
% in n variables.
%
% Example call: [xv,it]=broyden(x,f,n,tol)
% Requires an initial approximation column vector x. tol is required
% accuracy. User must define function f, for example see page 115.
% xv is the solution vector, parameter it is number of iterations
% taken. WARNING. Method may fail, for example, if initial estimates
% are poor.
% 
it=0; xv=x;
x0=x;
%Set initial Br
Br=eye(n);
[fr,f0]=feval(f, xv,varargin{:});
fprintf('iteration: ')

while norm(fr)>tol
  it=it+1;
  fprintf('%d,',it)
  pr=-Br*fr;
  tau=1;
  xv1=xv+tau*pr; xv=xv1;
  if any(xv./x0)>2
      xv=NaN;
      disp('not converged...')
      return;
  end
  oldfr=fr; [fr,f0]=feval(f,xv,varargin{:});
  %Update approximation to Jacobian using Broyden’s formula
  y=fr-oldfr; oldBr=Br;
  oyp=oldBr*y-pr; pB=pr'*oldBr;
  M=oyp*pB;
  Br=oldBr-M/(pr'*oldBr*y);
end
fprintf('\n');
end