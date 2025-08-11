clf; flag=0;
x=[1:.05:3];xx=[1:.005:3];
e=0.01*randn(size(x));
y=(ones(size(x))./sqrt((4-x.^2).^2+.02)).*(1+e);
p4=polyfit(x,y,4);yy4=polyval(p4,xx);
p8=polyfit(x,y,8);yy8=polyval(p8,xx);
p12=polyfit(x,y,12);yy12=polyval(p12,xx);
% Plot Figure 7.10.1
plot(x,y,'o',xx,yy4,xx,yy8,xx,yy12)
axis([1 3 -2 8]); xlabel('x'); ylabel('y')
Y=ones(size(x))./y.^2; X=x.^2; XX=xx.^2;
p=polyfit(X,Y,2), YY=polyval(p,XX);
for i=1:401
  if YY(i)<0
    disp('Transformation fails with this data set');
    flag=1;
    break
  end
end
if flag==0
  % Plot Figure 7.10.2
  figure(2);
  plot(X,Y,'o',XX,YY)
  axis([1 9 0 25]); xlabel('X'); ylabel('Y');
  yy=ones(size(YY))./sqrt(YY);
  % Plot Figure 7.10.3
  figure(3);
  plot(x,y,'o',xx,yy)
  axis([1 3 -2 8]); xlabel('x'); ylabel('y')
end