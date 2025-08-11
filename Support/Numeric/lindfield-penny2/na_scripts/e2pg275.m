nx=6; ny=6; hx=0.5; hy=0.3333;
by0=[0 0 0 0 0 0 0];
byn=[200 208.33 233.33 275 333.33 408.33 500];
bx0=[0 33.33 66.67 100 133.33 166.67 200];
bxn=[0 83.33 166.67 250 333.33 416.67 500];
F=zeros(ny+1,nx+1); G=F;
a=ellipgen(nx,hx,ny,hy,G,F,bx0,bxn,by0,byn);
aa=flipud(a);
contour(aa)
xlabel('node numbers in x direction');
ylabel('node numbers in y direction');