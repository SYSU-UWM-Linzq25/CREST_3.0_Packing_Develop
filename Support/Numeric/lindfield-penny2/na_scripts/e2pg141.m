x=-4:.1:0.5;
plot(x,f307(x)); grid on;
xlabel('x');ylabel('f(x)');
title('f(x)=(exp(x)-cos(x)) .^3');
root=fzero('f307',1.65,0.00005);
fprintf('The root of this equation is %6.4f\n',root);