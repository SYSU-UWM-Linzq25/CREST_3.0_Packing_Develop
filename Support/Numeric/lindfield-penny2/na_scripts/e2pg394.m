disp('Script 1; Symbolic - numeric solution')
c=1; v=zeros(3,21);
tic
syms a p u w
a=[1 2 3;4 5 6;5 7 9+p];
w=eig(a);
u=[];
for s=0:0.1:2
  u=[u,subs(w,p,s)];
end
v =sort(real(double(u)));
toc
v(:,[10 20])