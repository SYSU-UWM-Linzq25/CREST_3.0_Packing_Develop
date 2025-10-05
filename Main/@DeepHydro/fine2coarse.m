function LSMat=fine2coarse(this,parent,varSparse)
%% This function converts from fine temporal LS grids to coarse grids to save
%% out
% LSMat: a full matrix stores the LS image of the parent node in DE CS
%% input
% parent: the node to save
% varSparse: the LS variable in find grids
[rowE,colD,LSVal]=find(varSparse);
elevWhole=this.row2elev(rowE,parent.rowMin);
distWhole=this.col2dist(colD);
rowESave=this.elev2row(elevWhole,true,parent.rowMin);
colDSave=this.dist2col(distWhole,true);
indSave=sub2ind([parent.rowsESave,parent.colsDSave],rowESave,colDSave);
LSSave=accumarray(indSave,LSVal,[],@sum,[],true);
[indSave,~,LSSave]=find(LSSave);
[rowSave,colSave]=ind2sub([parent.rowsESave,parent.colsDSave],indSave);
LSSave=sparse(rowSave,colSave,LSSave,parent.rowsESave,parent.colsDSave);
LSMat=full(LSSave);
end