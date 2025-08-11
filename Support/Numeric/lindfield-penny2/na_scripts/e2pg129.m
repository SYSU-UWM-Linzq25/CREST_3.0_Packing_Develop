x=.75:.1:4.5; g=-0.5*(x.^3-6*x.^2+9*x-6);
plot(x,g); axis([.75,4.5,-1,4]);
hold on; plot(x,x);
xlabel('x'); ylabel('g(x)'); grid on;
ch=['o','+']; ty=0;
num=[ '0','1','2','3','4','5','6','7','8','9'];
for x1=[4.236067970 4.236067968]
  ty=ty+1;
  for i=1:19
    x2=-0.5*(x1^3-6*x1^2+9*x1-6);
    %First ten points very close, so represent by '0'
    if i==10,
      text(4.25,-.2,'0');
    elseif i>10
      text(x1,x2+.1,num(i-9));
    end;
    plot(x1,x2,ch(ty)); x1=x2;
  end;
end;
hold off