options=odeset('RelTol',0.5);
[t y]=ode23('f501',[0 60],100,options);
plot(t,y,'+');
xlabel('time');ylabel('y value');
hold on;
plot(t,90*exp(-0.1.*t)+10,'o'); % Exact solution.
hold off;