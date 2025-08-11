x=0:.25:6;
y=2+6*x.^2-x.^3;
y=y+randn(size(x));
Xd=[x.^2; x.^3; y];
al=zeros(2,15); al=['coeff x^2     :';'coeff x^3     :'];
b=mregg(Xd,1,0,al);