function [I,err]=GaussianLegendre1D(func,xd,xu,locX,multLocs,uniqueLocs,numOfOut,varargin)
%this version of GaussianLenegdre integration only use fixed number of
%points to perform numerical integration
tol=1e-5;
mx=(xu-xd)/2;
px=(xu+xd)/2;

index=5;
I=zeros(length(xu),numOfOut);
dI=Inf*ones(length(xu),numOfOut);
while sum(dI>tol)>0
%end pick out
% glcI=glc{index};
% nul=glcI(:,1);
% coe=glcI(:,2);
B=dI(:,1)>tol;
if ~isempty(varargin)
    vararginIn=cell(1,length(varargin));
    for parIndex=1:length(multLocs)
        par=varargin{multLocs(parIndex)};
        vararginIn{multLocs(parIndex)}=par(B);
    end
    for parIndex=1:length(uniqueLocs)
        par=varargin{uniqueLocs(parIndex)};
        vararginIn{uniqueLocs(parIndex)}=par;
    end
else
    vararginIn=[];
end
mxIn=mx(B);
pxIn=px(B);
[z,w]=Gaussian(index*2);
nul=z(end/2+1:end);
coe=w(end/2+1:end);
ILast=I;
Iout=GaussianInt1D(func,mxIn,pxIn,locX,multLocs,uniqueLocs,vararginIn,nul,coe);
I(B,:)=Iout;
dI=abs(I-ILast)./abs(I);
err=max(max(dI));
index=index+1;
end
end

function I=GaussianInt1D(func,mx,px,locX,multLocs,uniqueLocs,depVar,nul,coe)
%warp x independent variables
[XPar,Mx]=CreateX(nul,mx,px);
numOfGaussian=length(nul);
coe=coe';
coeX=repmat(coe,size(Mx,1),1);

coeX=coeX.*Mx;

%end warp x and y independent variables 
n=length(depVar);
%wrap other dependent variables
varargG=cell(1,n+1);
for parIndex=1:length(multLocs)
    minus=multLocs(parIndex)>=locX;
    par=depVar{multLocs(parIndex)};
    par=par(:);
    Par=repmat(par,[1,numOfGaussian]);
    Par=Par(:);
    varargG{multLocs(parIndex)+minus}=Par;
end
uniqueLocs1=uniqueLocs+(uniqueLocs>=locX);
varargG(uniqueLocs1)=depVar(uniqueLocs);
varargG{locX}=XPar;

%end wrap other dependent variables

%calculate integration of new waypoints
carg=length(coe);
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

XPar=CreateX(-nul,mx,px);
varargG=ReVar(XPar,locX,varargG);
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
function [XPar,Mx]=CreateX(nulX,mx,px)
%x=nulX*mx+px;
%y=nulY*my+py;
X=nulX;
[XPar,Mx]=meshgrid(X,mx);
Px=repmat(px,1,length(X));
clear X Y
XPar=XPar.*Mx+Px;
XPar=reshape(XPar,size(XPar,1)*size(XPar,2),1);
end

function varargG=ReVar(XPar,locX,varargG)
varargG{locX}=XPar;
end

function LoadGaussainCoff()
    global glc;
    S=load('gaussian_legendre.mat');
    glc=S.glc;
    global bCoffLoaded;
    bCoffLoaded=true;
    clear S
end