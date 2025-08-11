x=1; h(1)=.5; hvals=[ ]; dfbydx=[ ];
for i=1:17
  h=h/10; hvals=[hvals h]; dfbydx(i)=(f401(x+h)-f401(x))/h;
end;
exact=9; loglog(hvals,abs(dfbydx-exact),'*');
axis([1e-18 1 1e-8 1e4])
xlabel('h value'); ylabel('error in approximation');