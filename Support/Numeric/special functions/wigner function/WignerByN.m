function [DV,dDV]=WignerByN(X,n)
%produce m=0~n Wigner function and its derivative
Xs=sqrt(1-X.^2);
DV=legendre(n,X,'sch');
DV=DV';
DV(:,2:end)=DV(:,2:end)/sqrt(2);
%m=0~n-1
nDs=length(X);
m=0:n-1;
nm=sqrt((n-m).*(n+m+1));
NM=repmat(nm,[nDs,1]);
dDV=zeros(nDs,n+1);
dDV(:,1:n)=-NM.*DV(:,2:end)+((X./Xs)*m).*DV(:,1:n);
nm=sqrt(2*n);
dDV(:,end)=nm*DV(:,n)-n*X./Xs.*DV(:,end);
end