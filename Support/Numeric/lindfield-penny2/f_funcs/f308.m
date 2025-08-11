function f=f308(v,varargin)
v(isnan(v))=0;
x=v(:,1);y=v(:,2);
% set f vector to size required by function newtonmv.
nCells=size(v,1);
a=varargin{1};
b=varargin{2};
f=zeros(nCells,2);
f(:,1)=a.*(x.^2+y.^2)-4*a;
f(:,2)=a.*x+y-b;