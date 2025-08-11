%Solve a 120x120 linear equation system
A=rand(120); b=rand(120,1);
Tbefore=clock; tic; t0=cputime; flops(0);
y=A\b;
timetaken=etime(clock,Tbefore); tend=toc; t1=cputime-t0;
disp('etime     tic-toc   cputime')
fprintf('%5.2f%10.2f%10.2f\n\n', timetaken,tend,t1);
count=flops;
fprintf('flops = %6.0f\n',count);