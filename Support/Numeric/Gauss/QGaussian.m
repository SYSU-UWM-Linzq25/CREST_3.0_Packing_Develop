function [z,w]=QGaussian(n)
A=mp('1');
B=mp('2');
C=mp('3');
ind=mod(n,2);
num=floor(n/2)+ind;
z=mp(zeros(n,1));
w=mp(zeros(n,1));
for i=1:num
    M=mp(n+1-i);
    if i==1
       x=A-B/((n+A)*n);
    elseif i==2
       x=(z(n)-A)*4+z(n);
    elseif i==3
       x=(z(n-1)-z(n))*1.6+z(n-1); 
    elseif i>3
        if i==num && ind==1
            x=mp('0');
        else
            x=(z(M+1)-z(M+2))*C+z(M+3);
        end
    end
    nIter=0;
    nCheck=mp(eps);
    PB=mp('1');
    while nIter<100 && abs(PB)>nCheck*abs(x)
        PB=mp('1');
        nCheck=nCheck*10;
        PC=x;
        DJ=A;
        for j=2:n
           DJ=DJ+A;
           PA=PB;
           PB=PC;
           PC=x*PB+(x*PB-PA)*(DJ-A)/DJ;
        end
        PA=A/((PB-x*PC)*n);
        PB=PA*PC*(A-x^2);
        x=x-PB;
        nIter=nIter+1;
    end
    z(M)=x;
    w(M)=PA^2*(A-x^2);
    w(M)=B*w(M);
    if ind==0 || i<num
        z(i)=-z(M);
        w(i)=w(M);
    end
end
end