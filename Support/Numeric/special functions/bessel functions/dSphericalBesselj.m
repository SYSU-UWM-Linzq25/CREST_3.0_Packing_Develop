function v=dSphericalBesselj(nv,z,nb)
if nargin>2
  [vr,vi]=SphericalBesselj(nv+1,z,0,nb);
else
  [vr,vi]=SphericalBesselj(nv+1,z,0);
end
nn=nv;
v1r=vr(:,1:nv);
v2r=vr(:,2:nv+1);
v1i=vi(:,1:nv);
v2i=vi(:,2:nv+1);
nv=repmat(reshape(1:nv,1,nv),[length(z),1]);
z=reshape(z,length(z),1);
z=repmat(z,[1,nn]);
v=nv./z.*(v1r+1i*v1i)-(v2r+1i*v2i);
end