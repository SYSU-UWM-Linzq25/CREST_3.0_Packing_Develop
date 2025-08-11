function v=dSphericalBessely(nv,z,nb)
nn=nv;
if nargin>=3
    v=SphericalBessely(nv+1,z,nb);
else
    v=SphericalBessely(nv+1,z); 
end
v1=v(:,1:nv);
v2=v(:,2:nv+1);
nv=repmat(reshape(1:nv,1,nv),[length(z),1]);
z=reshape(z,length(z),1);
z=repmat(z,[1,nn]);
v=nv./z.*v1-v2;
end