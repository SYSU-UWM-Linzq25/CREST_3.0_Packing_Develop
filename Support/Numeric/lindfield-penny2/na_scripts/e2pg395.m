disp('Script 2; Numeric solution')
c=1; v=zeros(3,21);
tic
for p=0:.1:2
  a=[1 2 3;4 5 6;5 7 9+p];
  v(:,c)=sort(eig(a));
  c=c+1;
end
toc
v(:,[10 20])