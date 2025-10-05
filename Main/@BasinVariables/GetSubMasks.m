function GetSubMasks(obj,outRow,outCol,outName,maskDir)
disp('delineate subbasins using the watershed algorithm...')
GDT_Byte=1;
nOutlets=length(outRow);
[rows,cols]=size(obj.basinMask);
obj.masks=false(rows,cols,nOutlets);
cellsize=abs(obj.geoTrans(2));
if IsGeographic(obj.spatialRef,obj.geoTrans)
    cellsize=cellsize*110*1000;
end
% extract basin masks for each site
mkdir(maskDir);
for i=1:nOutlets
    disp(['clipping ', outName{i}]);
    % maski = extractbasin(obj.FAC,obj.FDR,outRow(i),outCol(i),cellsize,1,1,1);
    maski = extractbasin_s(obj.FDR,outRow(i),outCol(i));
    fileMask=[maskDir,outName{i},'_mask.tif'];
    obj.masks(:,:,i)=logical(maski);
    maski(~maski)=NaN;
    WriteRaster(fileMask,maski,obj.geoTrans,obj.spatialRef,GDT_Byte,'GTiff',255);
end
end