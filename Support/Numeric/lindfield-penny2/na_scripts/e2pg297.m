clf; nt=64; T=3.2; dt=T/nt
df=1/T
fmax=(nt/2)*df
t=0:dt:(nt-1)*dt; y=0.5 + 2*sin(2*pi*3.125*t)+cos(2*pi*6.25*t);
f=0:df:(nt-1)*df; Y=fft(y);
figure(1);
subplot(121); bar(real(Y),'r'); axis([0 63 -100 100])
xlabel('index k'); ylabel('real(DFT)')
subplot(122); bar(imag(Y),'r'); axis([0 63 -100 100])
xlabel('index k'); ylabel('imag(DFT)')
fss=0:df:(nt/2-1)*df;
Yss=zeros(1,nt/2); Yss(1:nt/2)=(2/nt)*Y(1:nt/2);
figure(2);
subplot(221); bar(fss,real(Yss),'r'); axis([0 10 -3 3])
xlabel('frequency Hz'); ylabel('real(DFT)')
subplot(222); bar(fss,imag(Yss),'r'); axis([0 10 -3 3])
xlabel('frequency Hz'); ylabel('imag(DFT)')
subplot(223); bar(fss,abs(Yss),'r'); axis([0 10 -3 3])
xlabel('frequency Hz'); ylabel('abs(DFT)')