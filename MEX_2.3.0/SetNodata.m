function SetNodata(fileRasIn,fileRasOut,noDataSrc,noDataDst,blockSize)
%% algorithm description
% This function consider all values in noDataSrc to NaN Nodata in the input
% raster, fileRas, and overwrite the input raster using the Nodata value specified in noDataDst 
if isempty(noDataSrc)
    error('At least one Nodata value in the source file needs to be specified.')
end
if length(noDataDst)~=1
    error('A unique Nodata value must be given for the output file');
end
%% determine the size and number of file blocks
[~,~,~,geoTrans,proj,dataType,NodataVal]=RasterInfo(fileRasIn);
[nR,nC,r0,c0,nRows,nCols,rowsImage,colsImage]=GetBlock(fileRasIn,blockSize);
fprintf(1,'Set Null:\n');
for iR=1:nR
    for iC=1:nC
        prog=((iR-1)*nC+iC)/(nR*nC);
        fprintf(1,'%d%%...',int32(prog*100));
        raster=ReadRaster(fileRasIn,r0(iR),c0(iC),nRows(iR),nCols(iC));
        raster(ismember(raster,noDataSrc))=NaN;
        WriteRaster(fileRasOut,raster,geoTrans,proj,dataType,'GTiff',noDataDst,r0(iR),c0(iC),rowsImage,colsImage);
        if prog<0.1
            fprintf(1,'\b\b\b\b\b');
        elseif prog<1
            fprintf(1,'\b\b\b\b\b\b');
        else
            fprintf(1,'\b\b\b\b\b\b\b');
        end
    end
end
fprintf(1,'Done!\n');
end