function [geoTransSub,r0,c0,rows,cols]=subsetgeoTrans(geoTrans,xLeft,yTop,xRight,yBtm)
[rowCorner,colCorner]= Proj2RowCol(geoTrans, [yTop;yBtm],[xLeft;xRight]);
r0=rowCorner(1);c0=colCorner(1);
rBtm=rowCorner(2);cBtm=colCorner(2);
rows=rBtm-r0+1;
cols=cBtm-c0+1;
[Ygeo,Xgeo]=RowCol2Proj(geoTrans,r0-0.5,c0-0.5);
geoTransSub=geoTrans;
geoTransSub(1)=Xgeo;
geoTransSub(4)=Ygeo;
end