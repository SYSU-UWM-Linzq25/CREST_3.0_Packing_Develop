function [DV,dDV,DVmT]=Wigner (X,NMAX,M,DVmT)
%% description
%Wigner function of Pi_nm and Tau_nm 
%d0mn(t)=(-1)^m*[(n-m)!/(n+m)!]^(1/2)*Pnm(cos(t))
%d0nm(t):DV(:,:)
%d(d0nm(t))/dt: dDV(:,:)

%input
%if M=0, ignore both input and output "DVmT"
%if M=1, supress the input "DVmT"
%otherwise, use the output "DVmT" from the calling of M-1 as input "DVmT"
%integer*8 M
%real*8,allocatable::X(:)
%mid
%real*8 factor
%real*8,allocatable::Xs(:),Xs1(:),DVmT(:),&
%                 DVT1(:),DVT2(:),DVT3(:)
%integer*8 NGAUSS,NMAX,cols,NM
%real*8 QMM        
%%
NGAUSS=length(X);
if (M==0) 
    NM=NMAX;
else
    NM=NMAX-M+1;
end
DV=zeros(NGAUSS,NM);
dDV=zeros(NGAUSS,NM);
% allocate(Xs1(NGAUSS),DVT1(NGAUSS),&
%           DVT2(NGAUSS),DVT3(NGAUSS))
Xs=sqrt(1-X.^2);
factor=sqrt((2*M-1)/2/M);
%initiate d0m(n) for all n>=m

if (M==0)
   DVT1=ones(NGAUSS,1);
   DVT2=X;
   for N=1:NMAX
      QN=N;
      QN1=N+1;
      QN2=2*N+1;
      DVT3=(QN2*X.*DVT2-QN*DVT1)/QN1;
      dDV(:,N)=(QN1*QN/QN2).*(-DVT1+DVT3)./Xs;
      DV(:,N)=DVT2;
      DVT1=DVT2;
      DVT2=DVT3;
   end
else
    if (M==1)
        DVmT=Xs*factor;
    else
    %for M greater than 1, previous DVmT must be input for later iteration
        DVmT=DVmT.*Xs*factor;
    end
    QMM=M^2;     
    DVT1=0;
    DVT2=DVmT;
    for N=M:NMAX
        NS=N-M+1;
        QN=N;
        QN2=2*N+1;
        QN1=N+1;
        QNM=sqrt(QN*QN-QMM);
        QNM1=sqrt(QN1*QN1-QMM);
        DVT3=(QN2*X.*DVT2-QNM*DVT1)/QNM1;
        dDV(:,NS)=(-QN1*QNM*DVT1+QN*QNM1*DVT3)./(QN2*Xs);
        DV(:,NS)=DVT2;
        DVT1=DVT2;
        DVT2=DVT3;
    end
end
end