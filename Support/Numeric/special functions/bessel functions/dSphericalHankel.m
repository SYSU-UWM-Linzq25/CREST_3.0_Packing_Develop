function v=dSphericalHankel(nv,z)
    v1=SphericalHankel(nv-1,z);
    v2=SphericalHankel(nv,z);
    v3=SphericalHankel(nv+1,z);
    v=(v1-(v2+v3.*z)./z)/2;
end