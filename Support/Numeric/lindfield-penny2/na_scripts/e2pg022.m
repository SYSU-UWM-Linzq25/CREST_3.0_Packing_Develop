% Example of the use of special graphics parameters in MATLAB
% illustrates the use of superscripts, subscripts,
% Fontsize and special characters
x=-5:.3:5;
plot(x,(1+x).^2.*cos(3*x),...
'linewidth',1,'marker','hexagram','markersize',12)
title('(\omega_2+x)^2\alpha*cos(\omega_1*x)','fontsize',14)
xlabel('x-axis');
ylabel('y-axis','rotation',0);
gtext('graph for \alpha = 2,\omega_2 =1 and \omega_1 =3')