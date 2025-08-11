% Fill b with square roots of 1 to 1000 using a for loop
clear;
tic;
for i =1:1000
  b(i)=sqrt(i);
end
t=toc;
disp(['Time taken for loop method is ', num2str(t)]);
