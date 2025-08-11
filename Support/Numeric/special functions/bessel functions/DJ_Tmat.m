function [vr,vi]=DJ_Tmat(nv,zr,zi,nb)
z=zr+1i*zi;
if nargin>=4
    [v1r,v1i]=SphericalBesselj(nv,z,0,nb);
    v2=dSphericalBesselj(nv,z,nb);
else
    [v1r,v1i]=SphericalBesselj(nv,zr,zi);
    v2=dSphericalBesselj(nv,z);
end  
z=reshape(z,length(z),1);
z=repmat(z,[1,nv]);
v=(v1r+1i*v1i)./z+v2;
vr=real(v);
vi=imag(v);
end