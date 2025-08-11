function [xv1,it,nc,index]=broyden_v2(x,Br,f,m,n,tol,maxIt,lb,ub,index,varargin)
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
indQuit=false(nCells,1);
fr=feval(f,xv1,index,varargin{:});
nfr=sqrt(sum(fr.^2,2));
index=nfr>tol;
% nDInsig=zeros(nCells,1);
while any(index) && it<maxIt
  it=it+1;
  pr=-MulDsMat(Br,fr);
  tau=1;
  dx=tau*pr(index,:);
  xv1(index,:)=xv1(index,:)+dx;
  indQuit(sum((xv1<lb)|(xv1>ub),2)>0)=true;
  index(indQuit)=false;
  oldfr=fr; 
  fr=feval(f,xv1,index,varargin{:});
%   fr=fr(:,1:n);
  %Update approximation to Jacobian using Broyden's formula
  y=fr-oldfr; 
  % n*m
  oldBr=Br;
%   oyp=oldBr*y-pr; pB=pr'*oldBr;
  % n*1
  oyp=MulDsMat(oldBr,y)-pr;
  % pr=pr',1*n
  pr=reshape(pr,[nCells,1,n]);
  % 1*m
  pB=MulDsMat(pr,oldBr);
  % n*m
  M=MulDsMat(oyp,pB);
  Br=oldBr-M./repmat(reshape(MulDsMat(pr,MulDsMat(oldBr,y)),[nCells,1,1]),[1,n,m]);
%   xv(index,:)=xv1;
  nfr=sqrt(sum(fr(index,:).^2,2));
  index(index)=(nfr>tol)|isnan(nfr);%&(nDInsig(index)<5);
end
index=index|indQuit;
xv1(index,:)=x(index,:);
nc=sum(index);
end