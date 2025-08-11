nt=32; T=1
dt=T/nt
t=0:dt:T-dt;
df=1/T
fmax=nt/(2*T)
f=0:df:df*(nt/2-1);
y=0.125*[8 7 6 5 4 3 2 1 0 -1 -2 -3 -4 -5 -6 -7 -8 ...
-7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7];
Yss=zeros(1,nt/2);
Y=fft(y); Yss(1:nt/2)=(2/nt)*Y(1:nt/2);
[f' abs(Yss)']