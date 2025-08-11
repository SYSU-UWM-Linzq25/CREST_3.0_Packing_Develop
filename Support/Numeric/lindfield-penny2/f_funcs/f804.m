function v=f804(x)
[m,n]=size(x); p=ones(m,n);
v=10+(p./((x-.16).^2+.1)).*sin(p./x);