nx=6; ny=6; hx=1/6; hy=1/6;
by0=[0 0 0 0 0 0 0]; byn=[0 0 0 0 0 0 0];
bx0=[0 0 0 0 0 0 0]; bxn=[0 0 0 0 0 0 0];
F=-ones(ny+1,nx+1); G=zeros(nx+1,ny+1);
a=ellipgen(nx,hx,ny,hy,G,F,bx0,bxn,by0,byn);
surfl(a)
axis([1 7 1 7 0 0.1])
xlabel('x-node nos.');ylabel('y-node nos.');zlabel('displacement');