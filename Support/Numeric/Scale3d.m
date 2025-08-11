function res=Scale3d(a,b)
%% multiply large 1-D matrix(a) and 3-D matrix(b)
% linear algebra matrix product is performed in [2,3] dimensions

%%
cr=size(a,1);
if cr~=size(b,1);
    error('matrix dimension dose not match');
end
rows=size(b,2);
cols=size(b,3);
res=zeros(cr,rows,cols);
for r=1:rows
    for c=1:cols  
        res(:,r,c)=a.*b(:,r,c);
    end
end
end