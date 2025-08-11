function [I,err]=GaussianLegendreFix(func,xd,xu,yd,yu,locX,locY,multLocs,uniqueLocs,numOfPoints,varargin)
%this version of GaussianLenegdre integration only use fixed number of
%points to perform numerical integration
LoadGaussainCoff();
global glc;
indexN=1;
for i=1:length(glc)
    if numOfPoints<=size(glc{i},1)*2;
        indexN=i;
        break;
    end
end
mx=(xu-xd)/2;
px=(xu+xd)/2;
my=(yu-yd)/2;
py=(yu+yd)/2;
I=zeros(length(xu),1);
if nargout==1
    indexN2=indexN;
else
    indexN2=indexN+1;
end
for index=indexN:indexN2
%end pick out
glcI=glc{index};
nul=glcI(:,1);
coe=glcI(:,2);
Iout=GaussianInt(func,mx,px,my,py,locX,locY,multLocs,uniqueLocs,varargin,nul,coe);
if index==indexN
    I=Iout;
end
dI=abs(I-Iout)./abs(I);
err=max(dI);
end
end

function I=GaussianInt(func,mx,px,my,py,locX,locY,multLocs,uniqueLocs,depVar,nul,coe)
%warp x and y independent variables
[XPar,YPar,Mx,My]=CreateXY(nul,nul,mx,px,my,py);
[coeX,coeY]=meshgrid(coe,coe);
coeX=coeX.*coeY;
coeX=reshape(coeX,1,length(coeX)*length(coeY));
coeX=repmat(coeX,size(Mx,1),1);
coeX=coeX.*Mx.*My;
clear coeY

%end warp x and y independent variables 
n=length(depVar);
%wrap other dependent variables
varargG=cell(1,n+2);
for parIndex=multLocs
    minus=(parIndex>locX)+(parIndex>locY);
    par=depVar{parIndex-minus};
    Par=repmat(par,[length(coe)^2,1]);
    varargG{parIndex}=Par;
end
uniqueLocs1=uniqueLocs-(uniqueLocs>locX)-(uniqueLocs>locY);
varargG(uniqueLocs)=depVar(uniqueLocs1);
varargG{locX}=XPar;
varargG{locY}=YPar;
clear X Y

%end wrap other dependent variables

%calculate integration of new waypoints
carg=length(coe)^2;
rarg=length(mx);    
% for i=1:na
%    varargG{i}=reshape(varargG{i},rarg*carg,1);
% end
I1=func(varargG{:});
nOut=size(I1,2);
I=zeros(rarg,nOut);
for i=1:nOut
I1i=reshape(I1(:,i),rarg,carg);
I1i=TrimNan(I1i,0);
I(:,i)=sum(coeX.*I1i,2);
end

[XPar,YPar]=CreateXY(-nul,nul,mx,px,my,py);
varargG=ReVar(XPar,YPar,locX,locY,varargG);
% for i=1:na
%    varargG{i}=reshape(varargG{i},rarg*carg,1);
% end
I1=func(varargG{:});
for i=1:nOut
I1i=reshape(I1(:,i),rarg,carg);
I1i=TrimNan(I1i,0);
I(:,i)=I(:,i)+sum(coeX.*I1i,2);
end

[XPar,YPar]=CreateXY(-nul,-nul,mx,px,my,py);
varargG=ReVar(XPar,YPar,locX,locY,varargG);
% for i=1:na
%    varargG{i}=reshape(varargG{i},rarg*carg,1);
% end
I1=func(varargG{:});
for i=1:nOut
I1i=reshape(I1(:,i),rarg,carg);
I1i=TrimNan(I1i,0);
I(:,i)=I(:,i)+sum(coeX.*I1i,2);
end

[XPar,YPar]=CreateXY(nul,-nul,mx,px,my,py);
varargG=ReVar(XPar,YPar,locX,locY,varargG);
% for i=1:na
%    varargG{i}=reshape(varargG{i},rarg*carg,1);
% end
I1=func(varargG{:});
for i=1:nOut
I1i=reshape(I1(:,i),rarg,carg);
I1i=TrimNan(I1i,0);
I(:,i)=I(:,i)+sum(coeX.*I1i,2);
end

clear  varargG I1 CoeX
%end calculate integration of new waypoints
end
function [XPar,YPar,Mx,My]=CreateXY(nulX,nulY,mx,px,my,py)
%x=nulX*mx+px;
%y=nulY*my+py;
[X,Y]=meshgrid(nulX,nulY);
X=reshape(X,1,length(nulX)*length(nulY));
Y=reshape(Y,1,length(nulX)*length(nulY));
[XPar,Mx]=meshgrid(X,mx);
Px=repmat(px,1,length(X));
[YPar,My]=meshgrid(Y,my);
Py=repmat(py,1,length(Y));
clear X Y
XPar=XPar.*Mx+Px;
YPar=YPar.*My+Py;
XPar=reshape(XPar,size(XPar,1)*size(XPar,2),1);
YPar=reshape(YPar,size(YPar,1)*size(YPar,2),1);
end

function varargG=ReVar(XPar,YPar,locX,locY,varargG)
varargG{locX}=XPar;
varargG{locY}=YPar;
end

function LoadGaussainCoff()
    global glc;
    S=load('gaussian_legendre.mat');
    glc=S.glc;
    global bCoffLoaded;
    bCoffLoaded=true;
    clear S
end