char=['o' '*' '+'];
for meth=1:3
  [t,x]=rkgen('f502',[0 3],1,.25,meth);
  re=(x-exp(-t))./exp(-t);
  plot(t,re,char(meth));
  axis([0 3 0 1.5e-4])
  xlabel('t');ylabel('relative error');
  hold on;
end;
hold off;