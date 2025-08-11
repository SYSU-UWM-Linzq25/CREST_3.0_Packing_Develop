function [TR,TI,TR1,TI1]=T_matrix_M(RGQR,RGQI,QR,QI)
    NMAX=size(QR,1)/2;
    Q=QR+1i*QI;
    RGQ=RGQR+1i*RGQI;
    T1=RGQ/Q;
    
    QQ=zeros(2*NMAX,2*NMAX);
    RGQQ=zeros(2*NMAX,2*NMAX);
    T11=T1;
    for i=1:NMAX
        for j=1:NMAX
            r0=2*(i-1)+1;
            c0=2*(j-1)+1;
            QQ(r0,c0)=Q(i,j);
            QQ(r0+1,c0)=Q(NMAX+i,j);
            QQ(r0,c0+1)=Q(i,NMAX+j);
            QQ(r0+1,c0+1)=Q(i+NMAX,j+NMAX);
            RGQQ(r0,c0)=RGQ(i,j);
            RGQQ(r0+1,c0)=RGQ(NMAX+i,j);
            RGQQ(r0,c0+1)=RGQ(i,NMAX+j);
            RGQQ(r0+1,c0+1)=RGQ(i+NMAX,j+NMAX);
            T11(r0,c0)=T1(i,j);
            T11(r0+1,c0)=T1(NMAX+i,j);
            T11(r0,c0+1)=T1(i,NMAX+j);
            T11(r0+1,c0+1)=T1(i+NMAX,j+NMAX);
        end
    end
    T1=T11;
    clear T11
    TR1=real(T1);
    TI1=imag(T1);
    Q=QQ;
    RGQ=RGQQ;
    clear QQ
    NMAX=2*NMAX;
    ratio=ones(NMAX,2);
    for i=1:NMAX
        Qi=Q(i,:);
        index=abs(Qi)>0;
        ratio(i,1)=min(abs(Qi(index)));
        Q(i,:)=Q(i,:)/ratio(i,1);
    end
    QN=Q(:,NMAX);
    index=abs(QN)>0;
    minabs=min(abs(QN(index)));
    for i=1:NMAX
        Qi=Q(:,i);
        index=abs(Qi)>0;
        ratio(i,2)=min(abs(Qi(index)))/minabs;
        Q(:,i)=Q(:,i)/ratio(i,2);
    end
    for i=1:NMAX
        RGQ(:,i)=RGQ(:,i)/ratio(i,2);
    end
    T=RGQ/Q;
    for i=1:NMAX-1
        T(:,i)=T(:,i)/ratio(i,1);
    end
    TR=real(T);
    TI=imag(T);
end