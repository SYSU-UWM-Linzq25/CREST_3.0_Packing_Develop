function res=MulDsMat(dsMat,mat)
%% multiply large 3-D matrix(a) and 3-D matrix(b)
% linear algebra matrix product is performed in [2,3] dimensions
% the first dimension stands for discrete elements
%%
m=size(dsMat,2);
n=size(mat,3);
mid=size(dsMat,3);
nDs=size(dsMat,1);
if mid~=size(mat,2)
    error('matrix dimensions do not match!')
end
res=zeros(nDs,m,n);
for r=1:m
    for c=1:n
        for k=1:mid
            res(:,r,c)=res(:,r,c)+dsMat(:,r,k).*mat(:,k,c);
        end
    end
end
end