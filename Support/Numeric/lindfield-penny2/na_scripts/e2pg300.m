clf
f1=20; f2=50; f3=70; nt=512; T=2; dt=T/nt
df=1/T
fmax=(nt/2)*df; t=0:dt:nt*dt; tt=0:dt/25:nt*dt/50;
y=0.2*cos(2*pi*f1*t)+0.35*sin(2*pi*f2*t)+0.3*sin(2*pi*f3*t);
yy=0.2*cos(2*pi*f1*tt)+0.35*sin(2*pi*f2*tt)+0.3*sin(2*pi*f3*tt);
y=y+0.5*randn(size(t)); yy=yy+0.5*randn(size(tt));
f=0:df:(nt/2-1)*df;
figure(1);
subplot(211), plot(tt,yy)
axis([0 0.04 -3 3])
xlabel('time sec'); ylabel('y')
yf=fft(y); yp=zeros(1,(nt/2));
yp(1:nt/2)=(2/nt)*yf(1:nt/2);
subplot(212), plot(f,abs(yp))
axis([0 fmax 0 0.5])
xlabel('frequency Hz'); ylabel('abs(DFT)');