function matrix=TrimNonValue(matrix,col)
sigma=matrix(:,col);
index=find((sigma<500).*(sigma>-500)==0);
matrix(index,:)=[];
end