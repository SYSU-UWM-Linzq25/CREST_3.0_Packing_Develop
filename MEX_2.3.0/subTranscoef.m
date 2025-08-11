function geoTransSub=subTranscoef(geoTrans,rowLT,colLT)
%% This function computes the geoTrans coefficients for a sub image whose left top corner is centered at (rowLT, colLT)
nOut=length(rowLT);
[Ygeo,Xgeo]=RowCol2Proj(geoTrans,rowLT,colLT);
geoTransSub=zeros(nOut,6);
geoTransSub(:,2)=geoTrans(2);
geoTransSub(:,3)=geoTrans(3);
geoTransSub(:,5)=geoTrans(5);
geoTransSub(:,6)=geoTrans(6);
geoTransSub(:,1)=Xgeo - geoTrans(2) - geoTrans(3)+ (geoTrans(2)+geoTrans(3))/2;
geoTransSub(:,4)=Ygeo - geoTrans(5) - geoTrans(6) + (geoTrans(5)+geoTrans(6))/2; 
end