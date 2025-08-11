function LSDE=offsetAChild(this,parent,child,varName,dist2O,elev2O)
%% This function offset a child node to the parent relative CS then add the LS contribution
%% output:
% LSDE: a sparse matrix (rowE,colD,LSDEValue) that records the offset grids
% of a LS variable
%% input
% parent: the parent node
% child: the child node
% varName: one of the LS variable Name
% dist2O, elev2O: the elevation difference and hydrological distance from
% the child node to the parent node
[rowEChild,colDChild,excSDE]=find(child.(varName));
dCol=this.diff2Out2grid(dist2O,true);
dRow=this.diff2Out2grid(elev2O,false);
rowEChild=rowEChild+child.rowMin+dRow-parent.rowMin;
colDChild=colDChild+dCol;
LSDE=sparse(rowEChild,colDChild,excSDE,parent.rowsE,parent.colsD);
end