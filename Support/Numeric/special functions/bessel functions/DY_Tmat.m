function v=DY_Tmat(nv,z,nb)
if nargin>=3
  v1=SphericalBessely(nv,z,nb);
  v2=dSphericalBessely(nv,z,nb);
else
  v1=SphericalBessely(nv,z);
  v2=dSphericalBessely(nv,z);
end
z=reshape(z,length(z),1);
z=repmat(z,[1,nv]);
v=v1./z+v2;
end