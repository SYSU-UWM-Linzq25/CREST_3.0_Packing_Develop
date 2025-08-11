function v=SphericalBessely(nv,z,nb)
nn=nv;
nv=1:nv;
nt=length(z);
if nargin>=3
    z=reshape(z,nt,1);
    nr=mod(nt,nb);
    cb=floor(nt/nb);
    if nr~=0
        cb=cb+1;
        z=[z;ones(nb-nr,1)];
    else
        nr=nb;
    end
    v=zeros(nb,cb,nn);
    z=reshape(z,nb,cb);
    parfor i=1:cb
        zn=z(:,i);
        if i==cb
           zn=zn(1:nr);
        end
        vn=bessely(nv+1/2,zn);
        zn=repmat(zn,[1,nn]);
        vn=sqrt(pi./(2*zn)).*vn;
        if i==cb
           vn=[vn;zeros(nb-nr,nn)];
        end
        v(:,i,:)=vn;
    end
    v=reshape(v,nb*cb,nn);
    v=v(1:nt,:);
else
    [nv,z]=meshgrid(nv,z);
    v=bessely(nv+1/2,z);
    v=sqrt(pi./(2*z)).*v;
end
end