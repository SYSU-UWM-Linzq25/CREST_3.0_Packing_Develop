hx=1/10; ht=1/10;
nx=16; nt=40;
c=1;t=0:nt;
hib=zeros(nt+1,1);
lowb=zeros(nt+1,1);
lowb(2:5,1)=10;
init=zeros(1,nx+1); initslope=zeros(1,nx+1);
u=fwave(nx,hx,nt,ht,init,initslope,lowb,hib,c);
surfl(u)
axis([0 16 0 40 -10 10])
xlabel('position along string'); ylabel('time');
zlabel('vertical displacement')