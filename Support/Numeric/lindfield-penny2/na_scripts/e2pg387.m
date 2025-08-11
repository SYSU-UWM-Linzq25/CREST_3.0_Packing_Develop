%script for Borweins(1986) iteration for pi
n=input('enter n')
y0=sqrt(2)-1; a0=6-4*sqrt(2); np=4;
for k=0:n
  yv=(1-y0^4)^.25;
  y1=(1-yv)/(1+yv);
  a1=a0*(1+y1)^4-2.0^(2*k+3)*y1*(1+y1+y1^2);
  rpval=a1;
  pval=vpa(1/rpval,np)
  a0=a1; y0=y1; np=4*np;
end