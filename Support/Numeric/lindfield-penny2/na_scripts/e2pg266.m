K=5e-7; hx=0.02; nx=15; % hx*nx=0.3
ht=440; nt=50; % ht*nt=22000
init=100*ones(1,nx+1);
lowb=20; hib=20;
u=heat(nx,hx,nt,ht,init,lowb,hib,K);
surfl(u)
axis([0 16 0 50 0 120])
view([-217 30])
xlabel('x - node nos.'); ylabel('time - node nos.');
zlabel('temperature')