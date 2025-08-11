function [geoTransSub,rowLT,colLT,rows,cols]=subsetgeoTrans(geoTrans,xLeft,yTop,xRight,yBtm)
[rowLT,colLT]= Proj2RowCol(geoTrans, yTop, xLeft);
geoTransSub=subTranscoef(geoTrans,rowLT,colLT);
[rowRB,colRB]= Proj2RowCol(geoTrans, yBtm, xRight);
rows=rowRB-rowLT+1;
cols=colRB-colLT+1;
end