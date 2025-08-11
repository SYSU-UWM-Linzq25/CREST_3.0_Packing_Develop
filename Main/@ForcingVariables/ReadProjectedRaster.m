function [raster,geoTransForc,spatialRefForc]=ReadProjectedRaster(fileName,band,...
                rowsBasic,colsBasic,geoTransBasic,spatialRefBasic,...
                decompBeforeSrc,decompAfterSrc,dirInt,pathSplitor,core,interpolationMethod) %Modified by Rehenuma
%,geoTransForcStored,srForceStored,mask)
[~,name,ext] = fileparts(fileName);
cmdDecomp=['!',decompBeforeSrc, ' '];
if strcmpi(ext,'.gz') || strcmpi(ext,'.z') || strcmpi(ext,'.tar')
    % if the file is compressed, a decompression process is
    % required
    fileDecomp=[dirInt,pathSplitor, name];
    if isempty(decompAfterSrc)
        decompAfterSrc=' ';
    end
    if strcmpi(pathSplitor,'\') % windows
        strcmd=[cmdDecomp, '"', fileName,'"', decompAfterSrc,'"',dirInt,'"'];
    else                        % linux
        strcmd=[cmdDecomp, '"', fileName,'"', decompAfterSrc,'"',fileDecomp,'"'];
    end
    eval(strcmd);
else
    fileDecomp=fileName;
end
clippedAndResampledFile=[dirInt,pathSplitor,name,'_',num2str(band),'_core_',num2str(core),'_temp.tif'];
outFormat='GTiff';
ResampleAndClip(geoTransBasic,spatialRefBasic,colsBasic,rowsBasic,fileDecomp,clippedAndResampledFile,outFormat,band,interpolationMethod); %Modified by Rehenuma
[raster,geoTransForc,spatialRefForc]=ReadRaster(clippedAndResampledFile);
deleteRaster(clippedAndResampledFile,outFormat);
if strcmpi(ext,'.gz') || strcmpi(ext,'.z') || strcmpi(ext,'.tar')
    % delete the decompressed file
    delete(fileDecomp);
end
end
