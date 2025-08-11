x=1:.2:2;
y=1./x;
interpval=aitken(x,y,1.03);
fprintf('interpolated value= %10.8f\n',interpval);