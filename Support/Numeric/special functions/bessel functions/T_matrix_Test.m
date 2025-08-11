function [T1,T2,err1,err2,scat1,scat2,ext1,ext2]=T_matrix_Test(RGQR,RGQI,QR,QI)
    NMAX=size(QR,1)/2;
    RGQ=RGQR+1i*RGQI;
    Q=QR+1i*QI;
    Q1=Q(1:NMAX,1:NMAX);
    Q2=Q(NMAX+1:2*NMAX,NMAX+1:2*NMAX);
    RGQ1=RGQ(1:NMAX,1:NMAX);
    RGQ2=RGQ(NMAX+1:2*NMAX,NMAX+1:2*NMAX);
    T10=RGQ1/Q1;
    I10=Q1/Q1;
    T20=RGQ2/Q2;
    I20=Q2/Q2;
    err11=max(max(abs(I10-eye(NMAX))));
    err12=max(max(abs(I20-eye(NMAX))));
    err1=max(err11,err12);
    clc
    T1=[T10,zeros(NMAX,NMAX);zeros(NMAX,NMAX),T20];
    ratio=ones(NMAX,2);
    minv1=abs(Q1(1,1));
    minv2=abs(Q2(1,1));
    for i=2:NMAX
        ratio(i,1)=max(abs(Q1(i,:)))/minv1;
        ratio(i,2)=max(abs(Q2(i,:)))/minv2;
    end
    for i=1:NMAX
        Q11(i,:)=Q1(i,:)/ratio(i,1);
        Q22(i,:)=Q2(i,:)/ratio(i,2);
    end
    T11=RGQ1/Q11;
    T22=RGQ2/Q22;
    I11=Q11/Q11;
    I22=Q22/Q22;
    for i=1:NMAX
        T11(:,i)=T11(:,i)/ratio(i,1);
        T22(:,i)=T22(:,i)/ratio(i,2);
    end
    err21=max(max(abs(I11-eye(NMAX))));
    err22=max(max(abs(I22-eye(NMAX))));
    err2=max(err21,err22);
    T2=[T11,zeros(NMAX,NMAX);zeros(NMAX,NMAX),T22];
    DN=2*(1:NMAX)'+1;
    v1=diag(T1);
    v2=diag(T2);
    scat1=sum(DN.*(abs(v1(1:NMAX)).^2+abs(v1(NMAX+1:2*NMAX)).^2));
    scat2=sum(DN.*(abs(v2(1:NMAX)).^2+abs(v2(NMAX+1:2*NMAX)).^2));
    ext1=sum(-DN.*(real(v1(1:NMAX))+real(v1(NMAX+1:2*NMAX))));
    ext2=sum(-DN.*(real(v2(1:NMAX))+real(v2(NMAX+1:2*NMAX))));
end