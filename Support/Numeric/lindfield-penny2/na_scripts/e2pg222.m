t0=0; tf=2; tinc=0.25; steps=floor((tf-t0)/tinc+1);
[t,x1]=abm('f503',[t0 tf],2,tinc);
[t,x2]=fhamming('f503',[t0 tf],2,tinc);
[t,x3]=rkgen('f503',[t0 tf],2,tinc,1);
disp('Solution of dy/dt=2yt')
disp('t        abm        Hamming    Classical     Exact');
for i=1:steps
  fprintf('%4.2f%12.7f%12.7f',t(i),x1(i),x2(i));
  fprintf('%12.7f%12.7f\n',x3(i),2*exp(t(i)*t(i)));
end