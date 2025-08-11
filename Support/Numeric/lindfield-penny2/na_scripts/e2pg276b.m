nx=6; ny=9; hx=1/6; hy=1/6; G=ones(10,7); mode=2;
[a,om]=ellipgen(nx,hx,ny,hy,G,mode);
om(1:5), mesh(a)
axis([1 8 1 10 -0.5 0.5])
xlabel('y - node nos.'); ylabel('x - node nos.');
zlabel('relative displacement');