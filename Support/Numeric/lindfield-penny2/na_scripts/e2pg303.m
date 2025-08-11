clf
y=[ones(1,5) zeros(1,59)];
nt=64; T=8;
dt=T/nt
df=1/T
fmax=(nt/2)*df;
f=0:df:(nt/2-1)*df;
yf=fft(y); yp=zeros(1,nt/2);
yp(1:nt/2)=(2/nt)*yf(1:nt/2);
figure(1); bar(f,abs(yp))
axis([0 fmax 0 0.2])
xlabel('frequency Hz'); ylabel('abs(DFT)')