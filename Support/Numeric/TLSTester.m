function TSLTester
tn=50;
xsTLS=[];
xsLS=[];
x0=[];
best=[];
best0=[];
for i=1:tn
n=7;
n1=3;
m=100;
A=rand(m,n);
x=rand(n,1);
b=A*x;
errA=0.2*randn(m,n-n1);
Ae=A;
Ae(:,n1+1:end)=Ae(:,n1+1:end)+errA;

errb=0.2*randn(m,1);
be=b+errb;
[xs,errEstA,errEstb]=TLS(Ae,be,n1);
xs2=linsolve(Ae,be);
x0=[x0;x];
xsTLS=[xsTLS;xs];
xsLS=[xsLS;xs2];

Aest=Ae;
Aest(:,n1+1:end)=Aest(:,n1+1:end)-errEstA;
besti=be-errEstb;
best0i=Aest*xs;
best=[best;besti];
best0=[best0;best0i];
end
figureTLS=figure;
axes1 = axes('Parent',figureTLS,'FontSize',14,'FontName','Times New Roman');
box(axes1,'on');
hold(axes1,'all');
plot(x0,xsTLS,'.');
hold on
err1=sqrt(sum((x0-xsTLS).^2)/n/tn);
plot(-0.2:1e-3:1.3,-0.2:1e-3:1.3);
axis([-0.2 1.3 -0.2 1.3]);
% title(strcat('errTLS=',num2str(err1)));
annotation(figureTLS,'textbox',...
    [0.183142857142857 0.714285714285715 0.318642857142857 0.0976190476190562],...
    'String',{'TSL solution',...
    strcat('RMSE=',num2str(err1))},...
    'FontSize',20,...
    'FontName','Times New Roman',...
    'FitBoxToText','off',...
    'EdgeColor',[1 1 1]);
annotation(figureTLS,'textbox',...
    [0.0438571428571428 0.942857142857143 0.0436428571428572 0.0452380952380978],...
    'String',{'a'},...
    'FontSize',20,...
    'FontName','Times New Roman',...
    'FitBoxToText','off',...
    'EdgeColor',[1 1 1]);

figureLS=figure;
axes2 = axes('Parent',figureLS,'FontSize',14,'FontName','Times New Roman');
box(axes2,'on');
hold(axes2,'all');
plot(x0,xsLS,'r.');
err2=sqrt(sum((x0-xsLS).^2)/n/tn);
hold on
plot(-0.2:1e-3:1.3,-0.2:1e-3:1.3);
annotation(figureLS,'textbox',...
    [0.183142857142857 0.714285714285715 0.318642857142857 0.0976190476190562],...
    'String',{'LS solution',...
    strcat('RMSE=',num2str(err2))},...
    'FontSize',20,...
    'FontName','Times New Roman',...
    'FitBoxToText','off',...
    'EdgeColor',[1 1 1]);
annotation(figureLS,'textbox',...
    [0.0438571428571428 0.942857142857143 0.0436428571428572 0.0452380952380978],...
    'String',{'b'},...
    'FontSize',20,...
    'FontName','Times New Roman',...
    'FitBoxToText','off',...
    'EdgeColor',[1 1 1]);
axis([-0.2 1.3 -0.2 1.3]);

figure;
plot(best,best0,'.');

end