function [value,bDistributed]=readVarInfo(gfileID,keywordType,...
                keywordVar,commentSymbol,pDir,...
                keywordUseExt,keywordExtPath,...
                geoTrans,proj,basinMask)
if ~isempty(keywordType)
    value=ModelParameters.ReadAKeyword(gfileID,keywordType,commentSymbol);
    if strcmpi(value,'distributed')==1
       bDistributed=true;
    else
       bDistributed=false;
    end
else
    bDistributed=true;
end

if bDistributed
    if ~isempty(keywordUseExt)
        useExt=ModelParameters.ReadAKeyword(gfileID,keywordUseExt,commentSymbol);
    else
        useExt='no';
    end
    if strcmpi(useExt,'yes')==1
        fileExt=ModelParameters.ReadAKeyword(gfileID,keywordExtPath,commentSymbol);
    end
end
value=ModelParameters.ReadAKeyword(gfileID,keywordVar,commentSymbol);
if bDistributed
    value=[pDir,value];
    [tarYSize,tarXSize]=size(basinMask);
    if strcmpi(useExt,'yes')==1
        ResampleAndClip(geoTrans,proj,tarXSize,tarYSize,fileExt,value,'GTiff');
        [raster,~,~,dataType,NoDataVal]=ReadRaster(value);
        raster(~basinMask)=NaN;
        WriteRaster(value,raster,geoTrans,proj,dataType,'GTiff',NoDataVal);
    end
else
    value=str2double(value);
end
end