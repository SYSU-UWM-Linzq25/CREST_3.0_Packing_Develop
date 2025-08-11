function CreateRefMask(fileRefMask,fileARef,fileBasinMask)
%% Algorithm Description 
% This function creates a reference mask file defined by the basin mask file that records 
% the 1d-index of cells in the reference file. 
% The resolution of the reference file is supposed coarser than the basin mask file so that
% a given index is expected to be appear in multiple cells in the output
% mask.
% This function helps preprocess
%% input
% fileRefMask: the output reference mask file
% fileARef: the original reference file
% fileBasinMask: basin mask
%% add a geotransformation 
GDALLoad();
NoDataVal=-9999;
%% if fileARef does not have a decent projection, uncomment and modify the lines below
% yllcorner=25.84;
% xllcorner=-128.20;
% cellsize=0.07272727;
% nRows=538;
% GDT_Float=6;
% addCS(xllcorner,yllcorner,cellsize,nRows,NoDataVal,GDT_Float,fileARef,fileBasinMask);
%% get the mask
[~,rows,cols,geoTrans,proj]=RasterInfo(fileARef);
[col,row]=meshgrid(1:cols,1:rows);
ind=sub2ind([rows,cols],row,col);
clear data
[dirOut,~,~]=fileparts(fileRefMask);
tempRaster=[dirOut,'\RefMaskTemp.tif'];
GDT_Int32=5;
WriteRaster(tempRaster,ind,geoTrans,proj,GDT_Int32,'GTiff',NoDataVal);
clear ind
[~,tarYSize,tarXSize,geoTransTar,wktTar]=RasterInfo(fileBasinMask);
ResampleAndClip(geoTransTar,wktTar,tarXSize,tarYSize,tempRaster,fileRefMask,'GTiff',1);
[dataMask,geoTransTar,wktTar,dataType,NoDataVal]=ReadRaster(fileRefMask);
basinMask=ReadRaster(fileBasinMask);
dataMask(isnan(basinMask))=NaN;
WriteRaster(fileRefMask,dataMask,geoTransTar,wktTar,dataType,'GTiff',NoDataVal);
delete(tempRaster);
end