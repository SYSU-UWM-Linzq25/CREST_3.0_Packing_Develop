option=odeset('RelTol',0.0005);
s=-1.25:-0.25:-2; s0=[ ];
ncase=length(s); b=zeros(1,ncase);
for i=1:ncase
  [x,y]=ode45('f601',[1 2],[1 s(i)],option);
  [m,n]=size(y); b(1,i)=y(m,1);
end
s0=aitken1(b,s,1)
[x,y]=ode45('f601',[1 2],[1 s0],option);
[x y(:,1)]