function res=Mul3d(a,b)
%% multiply large 3-D matrix
% linear algebra matrix product is performed in [2,3] dimensions

%%
cr=size(a,3);
if cr~=size(b,2);
    error('matrix dimension dose not match');
end
rows=size(a,2);
cols=size(b,3);
res=zeros(size(a,1),rows,cols);
for r=1:rows
    for c=1:cols
        for i=1:cr
            res(:,r,c)=res(:,r,c)+a(:,r,i).*b(:,i,c);
        end
    end
end

end