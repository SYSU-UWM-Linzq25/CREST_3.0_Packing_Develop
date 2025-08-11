function GetBasinMaskFrmGlobal(xLocOut,yLocOut,srOutlet,DEMExt,FDRExt,FACExt,streamExt,fileMask,fileDEM,fileFDR,fileFAC,fileStream,outFormat)
[FDRGlobal,geoTransGlobal,srGlobal]=ReadRaster(FDRExt);
FACGlobal=ReadRaster(FACExt);
[XOutGlobal,YOutGlobal]=ProjTransform(srOutlet,srGlobal,xLocOut,yLocOut);
[outRow,outCol]= Proj2RowCol(geoTransGlobal, YOutGlobal, XOutGlobal);
cellsize=abs(geoTransGlobal(2));
if IsGeographic(srGlobal,geoTransGlobal)
    cellsize=cellsize*110*1000;
end
maskOut = extractbasin(FACGlobal,FDRGlobal,outRow,outCol,cellsize,1,1,1);
clear FDRGlobal FACGlobal
maxCol=max(maskOut,[],1);
colLeft=find(maxCol,1,'first');
colRight=find(maxCol,1,'last');
maxRow=max(maskOut,[],2);
rowTop=find(maxRow,1,'first');
rowBtm=find(maxRow,1,'last');
geoTrans=geoTransGlobal;
[Ygeo,Xgeo]=RowCol2Proj(geoTransGlobal,rowTop-0.5,colLeft-0.5);
geoTrans(1)=Xgeo;
geoTrans(4)=Ygeo;
maskOut(:,colRight+1:end)=[];
maskOut(:,1:colLeft-1)=[];
maskOut(rowBtm+1:end,:)=[];
maskOut(1:rowTop-1,:)=[];
GDT_Int32=5;
NoDataValue=-9999;
maskOut(~maskOut)=NaN;
WriteRaster(fileMask,maskOut,geoTrans,srGlobal,GDT_Int32,outFormat,NoDataValue);
%% fdr
[tarYSize,tarXSize]=size(maskOut);
ResampleAndClip(geoTrans,srGlobal,tarXSize,tarYSize,FDRExt,fileFDR,outFormat);
[fdr,~,~,dataType]=ReadRaster(fileFDR);
fdr(isnan(maskOut))=NaN;
WriteRaster(fileFDR,fdr,geoTrans,srGlobal,GDT_Int32,outFormat,NoDataValue);
%% fac
ResampleAndClip(geoTrans,srGlobal,tarXSize,tarYSize,FACExt,fileFAC,outFormat);
[fac,~,~,dataType]=ReadRaster(fileFAC);
fac(isnan(maskOut))=NaN;
WriteRaster(fileFAC,fac,geoTrans,srGlobal,dataType,outFormat,NoDataValue);
%% dem
ResampleAndClip(geoTrans,srGlobal,tarXSize,tarYSize,DEMExt,fileDEM,outFormat);
[dem,~,~,dataType]=ReadRaster(fileDEM);
dem(isnan(maskOut))=NaN;
WriteRaster(fileDEM,dem,geoTrans,srGlobal,dataType,outFormat,NoDataValue);
%% stream
ResampleAndClip(geoTrans,srGlobal,tarXSize,tarYSize,streamExt,fileStream,outFormat);
stream=ReadRaster(fileStream);
stream(isnan(maskOut))=NaN;
stream(stream~=1)=NaN;
WriteRaster(fileStream,stream,geoTrans,srGlobal,GDT_Int32,outFormat,NoDataValue);
end