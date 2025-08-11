function [vr,vi]=QSphericalBesselj(nv,zr,zi,nb)
%nv must be a scalar
z=zr+1i*zi;
z=reshape(z,length(z),1);
nn=nv;
nv=1:nv;
if nargin>3 % multicore
    nt=length(z);
    nr=mod(nt,nb);
    cb=floor(nt/nb);
    if nr~=0
        cb=cb+1;
        z=[z;ones(nb-nr,1)];
    else
        nr=nb;
    end
    z=reshape(z,nb,cb);
    vn=zeros(nb,cb,nn);
    for i=1:cb
       zn=z(:,i);
       if i==cb
           zn=zn(1:nr);
       end
       v=besselj(nv+1/2,zn);
       zn=repmat(zn,[1,nn]);
       v=sqrt(pi./(2*zn)).*v;
       if i==cb
           v=[v;zeros(nb-nr,nn)];
       end
       vn(:,i,:)=v;
    end
    vn=reshape(vn,nb*cb,nn);
    vn=vn(1:nt,:);
    vr=real(vn);
    vi=imag(vn);
else   %single core
     v=besselj(nv+1/2,z);
     v=sqrt(pi./(2*repmat(z,[1,nn]))).*v;
     vr=real(v);
     vi=imag(v);
end
end