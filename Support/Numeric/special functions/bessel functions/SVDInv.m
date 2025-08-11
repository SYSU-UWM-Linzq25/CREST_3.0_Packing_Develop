function [Ai,err,err2]=SVDInv(A)
    [U,S,V]=svd(A);
    Ui=inv(U);
    Vi=inv(V');
    n=size(A,1);
    Si=S;
    for i=1:n
        Si(i,i)=1/Si(i,i);
    end
    Ai=Vi*Si*Ui;
    I=A*Ai;
    err=max(max(abs(eye(n)-I)));
    I2=zeros(n,n);
    for i=1:n
        I2(i,:)=A(i,:)/A;
    end
    err2=max(max(abs(eye(n)-I2)));
end