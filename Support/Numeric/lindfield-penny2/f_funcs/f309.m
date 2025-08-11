function jf=f309(v)
x=v(1);y=v(2);
% set jf matrix to size required by function newtonmv.
jf=zeros(2,2);
% each row of jf is assigned the appropriate partial derivatives.
jf(1,:)=[2*x 2*y];
jf(2,:)=[y x];