function raster=ReadRasterExt(fileName,r0,c0,rows,cols,fillVal)
%% use this fucntion when the reading area is potentially larger than the source data
%% input
% (r0,c0) can be smaller than 1
% (rows,cols) can be potentially larger than the extent of the source data
[~,rowsSrc,colsSrc]=RasterInfo(fileName);
bOut=false;
if r0<1
    r0Act=1;
    r0Mat=2-r0;
elseif r0>rowsSrc
    bOut=true;
else
    r0Act=r0;
    r0Mat=1;
end
if c0<1
    c0Act=1;
    c0Mat=2-c0;
elseif c0>colsSrc
    bOut=true;
else
    c0Act=c0;
    c0Mat=1;
end
if bOut
    raster=fillVal*ones(rows,cols);
    return;
end
rowsEnd=min(r0+rows-1,rowsSrc);
colsEnd=min(c0+cols-1,colsSrc);
rowsAct=rowsEnd-r0Act+1;
colsAct=colsEnd-c0Act+1;
rasData=ReadRaster(fileName,r0Act,c0Act,rowsAct,colsAct);
raster=fillVal*ones(rows,cols);
raster(r0Mat:r0Mat+rowsAct-1,c0Mat:c0Mat+colsAct-1)=rasData;
end