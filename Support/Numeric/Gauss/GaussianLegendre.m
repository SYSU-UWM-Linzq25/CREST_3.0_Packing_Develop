function [I,index]=GaussianLegendre(func,xd,xu,yd,yu,locX,locY,tol,varargin)
%this version of GaussianLenegdre integration only go on iterating
%inprecise integrals

% global bCoeffLoaded;
% if ~bCoeffLoaded
%     LoadGaussainCoff();
%     bCoeffLoaded=true;
% end
% LoadGaussainCoff();
% global glc;

mx=(xu-xd)/2;
px=(xu+xd)/2;
my=(yu-yd)/2;
py=(yu+yd)/2;
index=2;
I=zeros(length(xu),1);
dI=Inf*ones(length(xu),1);
while sum(dI>tol)>0
    %pick out the inprecise integral in I vector
    B=dI>tol;
    n=length(varargin);
    if ~isempty(varargin)
        vararginIn=cell(1,length(varargin));
        for parIndex=1:n
            par=varargin{parIndex};
            vararginIn{parIndex}=par(B);
        end
        
    else
        vararginIn=[];
    end
    mxIn=mx(B);myIn=my(B);
    pxIn=px(B);pyIn=py(B);
    %end pick out
%     glcI=glc{index};
    [z,w]=Gaussian(index*2);
    nul=z(end/2+1:end);
    coe=w(end/2+1:end);
    ILast=I;
    Iout=GaussianInt(func,mxIn,pxIn,myIn,pyIn,locX,locY,vararginIn,nul,coe);
    I(B)=Iout;
    dI=abs(I-ILast)./abs(I);
%     dIi=abs(imag(I-ILast)./imag(I));
%     dI=max(dIr,dIi);
    index=index+1;
end
end

function I=GaussianInt(func,mx,px,my,py,locX,locY,depVar,nul,coe)
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
par=[];
for parIndex=1:n
    par=depVar{parIndex};
    Par=repmat(par,1,size(XPar,2));
    varargG{parIndex}=Par;
end
if ~isempty(par)
    for i=n+1:-1:locX+1
        varargG{i}=varargG{i-1};
    end
    %varargG{locX+1:n+1}=varargG(locX:n);
    varargG{locX}=XPar;
    for i=n+2:-1:locY+1
        varargG{i}=varargG{i-1};
    end
%    varargG{locY+1:n+2}=varargG{locY:n+1};
    varargG{locY}=YPar;
else
    varargG{locX}=XPar;
    varargG{locY}=YPar;
end
clear X Y

%end wrap other dependent variables

%calculate integration of new waypoints
na=length(varargG);
[rarg,carg]=size(varargG{1});
for i=1:na
   varargG{i}=reshape(varargG{i},rarg*carg,1);
end
I1=func(varargG{:});
I1=reshape(I1,rarg,carg);
I1=TrimNan(I1,0);
I=sum(coeX.*I1,2);

[XPar,YPar]=CreateXY(-nul,nul,mx,px,my,py);
varargG=ReVar(XPar,YPar,locX,locY,varargG);
for i=1:na
   varargG{i}=reshape(varargG{i},rarg*carg,1);
end
I1=func(varargG{:});
I1=reshape(I1,rarg,carg);
I1=TrimNan(I1,0);
I=I+sum(coeX.*I1,2);

[XPar,YPar]=CreateXY(-nul,-nul,mx,px,my,py);
varargG=ReVar(XPar,YPar,locX,locY,varargG);
for i=1:na
   varargG{i}=reshape(varargG{i},rarg*carg,1);
end
I1=func(varargG{:});
I1=reshape(I1,rarg,carg);
I1=TrimNan(I1,0);
I=I+sum(coeX.*I1,2);

[XPar,YPar]=CreateXY(nul,-nul,mx,px,my,py);
varargG=ReVar(XPar,YPar,locX,locY,varargG);
for i=1:na
   varargG{i}=reshape(varargG{i},rarg*carg,1);
end
I1=func(varargG{:});
I1=reshape(I1,rarg,carg);
I1=TrimNan(I1,0);
I=I+sum(coeX.*I1,2);

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
end

function varargG=ReVar(XPar,YPar,locX,locY,varargG)
varargG{locX}=XPar;
varargG{locY}=YPar;
end