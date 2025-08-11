% Fill b with square roots of 1 to 1000 using a vector
clear;
tic;
a=1:1:1000;
b=sqrt(a);
t=toc;
disp(['Time taken for vector method is ',num2str(t)]);