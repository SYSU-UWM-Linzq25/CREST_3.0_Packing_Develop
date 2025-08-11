function [XZeros,WeightsX]=CreateLegendreZerosAndWeights(numOfPoints,lx,ux)
[nul,coe]=LoadGaussainCoff(numOfPoints);
[XZeros1,WeightsX1]=CreateX(nul,coe,lx,ux);
XZeros2=CreateX(-nul,coe,lx,ux);
XZeros=[flipdim(XZeros2,2),XZeros1];
WeightsX=[flipdim(WeightsX1,2),WeightsX1];
end

function [XPar,WeightsX]=CreateX(nulX,coe,lx,ux)
mx=(ux-lx)/2;
px=(ux+lx)/2;
X=nulX;
[XPar,Mx]=meshgrid(X,mx);
Px=repmat(px,1,length(X));
clear X Y
XPar=XPar.*Mx+Px;
WeightsX=(coe*(mx'))';
end

function [nul,coe]=LoadGaussainCoff(numOfPoints)
S=load('gaussian_legendre.mat');
glc=S.glc;
index=inf;
for i=1:length(glc)
    if numOfPoints<=size(glc{i},1)*2;
        index=i;
        break;
    end
end
glcI=glc{index};
nul=glcI(:,1);
coe=glcI(:,2);
end