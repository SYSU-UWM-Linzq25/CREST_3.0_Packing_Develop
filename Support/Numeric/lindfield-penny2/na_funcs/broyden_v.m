function [xv1,it,nc]=broyden_v(x,Br,f,n,tol,tol2,maxIt,index,varargin)
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
it=0; xv1=x;
nCells=size(x,1);
% index=true(nCells,1);
fr=feval(f,xv1,index,varargin{:});
%Set initial Br
% Br=-1/1013*eye(n);
% Br=reshape(Br,[1,n,n]);
% Br=repmat(Br,[nCells,1,1]);
nfr=sqrt(sum(fr(:,1:n).^2,2));
index=nfr>tol;
% xv1=xv;
nDInsig=zeros(nCells,1);
while any(index) && it<maxIt
  it=it+1;
%   Br=Br(iindex,:,:);
%   fr=fr(iindex,1:n);
  pr=-MulDsMat(Br,fr);
  tau=1;
  dx=tau*pr(index,:);
  isInsig=max(abs(dx),[],2)<tol2;
  nDInsig(index)=nDInsig(index).*isInsig+isInsig;
  xv1(index,:)=xv1(index,:)+dx;
  oldfr=fr; 
  fr=feval(f,xv1,index,varargin{:});
%   fr=fr(:,1:n);
  %Update approximation to Jacobian using Broyden's formula
  y=fr-oldfr; 
  oldBr=Br;
%   oyp=oldBr*y-pr; pB=pr'*oldBr;
  oyp=MulDsMat(oldBr,y)-pr;
  pr=reshape(pr,[nCells,1,n]);
  pB=MulDsMat(pr,oldBr);
  M=MulDsMat(oyp,pB);
  Br=oldBr-M./repmat(MulDsMat(pr,MulDsMat(oldBr,y)),[1,n,n]);
%   xv(index,:)=xv1;
  nfr=sqrt(sum(fr(index,:).^2,2));
  index(index)=(nfr>tol)&(nDInsig(index)<5);
%   iindex=nfr>tol;
%   index(index)=iindex;
%   nCells=sum(index);
end
xv1(index,:)=x(index,:);
nc=sum(index);
end