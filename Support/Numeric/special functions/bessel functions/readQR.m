function [QR,QI,RGQR,RGQI]=readQR(path,NMAX)
NMAX=NMAX*2;
f1=strcat(path,'\QR.txt');
f2=strcat(path,'\QI.txt');
f3=strcat(path,'\RGQR.txt');
f4=strcat(path,'\RGQI.txt');
format long
f1h=fopen(f1,'r');
f2h=fopen(f2,'r');
f3h=fopen(f3,'r');
f4h=fopen(f4,'r');
fmt='%f';
QR= fscanf(f1h, fmt);
QI=fscanf(f2h,fmt);
QR=reshape(QR,NMAX,NMAX);
QR=QR';
QI=reshape(QI,NMAX,NMAX);
QI=QI';
RGQR= fscanf(f3h, fmt);
RGQI=fscanf(f4h,fmt);
RGQR=reshape(RGQR,NMAX,NMAX);
RGQR=RGQR';
RGQI=reshape(RGQI,NMAX,NMAX);
RGQI=RGQI';
fclose('all');
end