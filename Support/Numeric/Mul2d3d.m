function res=Mul2d3d(a,b)
%% multiply large 2-D matrix(a) and 3-D matrix(b)
% linear algebra matrix product is performed in [2,3] dimensions

%%
cr=size(a,2);
if cr~=size(b,2);
    error('matrix dimensions do not match');
end
rows=size(a,1);
cols=size(b,3);
res=zeros(size(b,1),rows,cols);
for r=1:rows
    for c=1:cols
        for i=1:cr
            res(:,r,c)=res(:,r,c)+a(r,i)*b(:,i,c);
        end
    end
end

end