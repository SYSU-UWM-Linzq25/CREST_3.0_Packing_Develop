function TSLTester2
tn=100;
xsTLS=[];
xsLS=[];
x0=[];
m=40;
for i=1:tn
Rhh=rand(m,1);
A(:,2)=Rhh;
A(:,1)=1;
A(:,3)=A(:,2).^2;
x=rand(3,1);
b=A*x;
sigRhh=0.05*(max(Rhh)-min(Rhh));
errRhh=sigRhh*randn(m,1);
Rhhe=Rhh+errRhh;
errb=0.05*randn(m,1)*(max(b)-min(b));
be=b+errb;
Ae(:,2)=Rhhe(2:end).^2-Rhhe(1).^2;
Ae(:,1)=Rhhe(2:end)-Rhhe(1);
Be=(be(2:end)-be(1));
% indexOut=abs(Rhhe(2:end)-Rhhe(1))<(3*sigRhh);
% Ae(indexOut,:)=[];
% Be(indexOut)=[];
plot(Ae*x(2:3),Be,'.');
xs=zeros(3,1);
xs(2:3)=TLS(Ae,Be,0);
xs(1)=mean(be-xs(2)*Rhhe-xs(3)*Rhhe.^2);
AeLS(:,2)=Rhhe;
AeLS(:,1)=1;
AeLS(:,3)=Rhhe.^2;
xs2=linsolve(AeLS,be);
x0=[x0;x];
xsTLS=[xsTLS;xs];
xsLS=[xsLS;xs2];
end
plot(x0,xsTLS,'.');
hold on
err1=sqrt(sum((x0-xsTLS).^2)/3/tn);
plot(min(xsTLS):1e-3:max(xsTLS),min(xsTLS):1e-3:max(xsTLS))
title(strcat('errTLS=',num2str(err1)));
figure
plot(x0,xsLS,'r.');
err2=sqrt(sum((x0-xsLS).^2)/3/tn);
hold on
plot(min(xsLS):1e-3:max(xsLS),min(xsLS):1e-3:max(xsLS))
title(strcat('errLS=',num2str(err2)));
end