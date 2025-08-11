global c1
ro=[ ];ve=[ ];x=[ ];
c=.5:.1:1.1;
u=log(1+1 ./c);
x=c.*u.*(1-log((1+c).*u)./(1+u));
%Now solve equation using MATLAB function fzero
i=0;
for c1=.5:.1:1.1
  i=i+1;
  ro(i)=fzero('f301',1,0.00005);
end;
plot(x,c,'+');
axis([.4 .6 .5 1.2]);
hold on
plot(ro,c,'o');
xlabel('root x value'); ylabel('c value');
hold off