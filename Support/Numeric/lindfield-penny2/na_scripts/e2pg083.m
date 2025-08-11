a=[1 1;2.05 -1;3.06 1;-1.02 2;4.08 -1];
b=[1.98;0.95;3.98;0.92;2.90];
x=pinv(a)*b
norm_pinv=norm(a*x-b)
x=a\b
norm_op=norm(a*x-b)