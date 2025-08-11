function c=NormalizedCross(a,b,dim)
c=cross(a,b,dim);
mod=sqrt(sum(c.^2,dim));
index=(mod<1e-12);
ic=find(index);
c=Scale3d(1./sqrt(sum(c.^2,dim)),c);
c(index,:)=0;
end