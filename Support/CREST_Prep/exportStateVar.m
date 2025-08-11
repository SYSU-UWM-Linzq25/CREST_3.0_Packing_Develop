function exportStateVar(pathStateVar,dnStart,dnEnd,step,fmt,demRef)
SECONDS_PER_DAY=86400;
GDALLoad();
dnCur=dnStart;
pathStateExportVar=[pathStateVar,'export/'];
[~,~,~,geoTrans,sr]=RasterInfo(demRef);
dataType=6;
NoDataValue=-9999;
outFmt='GTiff';
mkdir(pathStateExportVar);
while dnCur<=dnEnd
    ds=datestr(dnCur,fmt);
    disp(['exporting ' ds]);
    statefileName=[pathStateVar,ds,'.mat'];
    stateVar=matfile(statefileName);
    detail=whos(stateVar);
    names={detail.name};
    for i=1:length(names)
        dirVar=[pathStateExportVar,names{i},'\'];
        if exist(dirVar,'dir')~=7
            mkdir(dirVar);
        end
        outFileName=[dirVar,ds,'.tif'];
        if ~strcmp(names{i},'W')
            cmd=['WriteRaster(outFileName,stateVar.', names{i},',geoTrans,sr,dataType,outFmt,NoDataValue)'];
            eval(cmd)
        else
            for b=1:3
               outFileName_b=[dirVar,ds,'_',num2str(b),'.tif'];
               cmd=['WriteRaster(outFileName_b,stateVar.', names{i},'(:,:,b),geoTrans,sr,dataType,outFmt,NoDataValue)']; 
               eval(cmd)
            end
        end
    end
    dnCur=(round(SECONDS_PER_DAY*dnCur)+round(SECONDS_PER_DAY*step))/SECONDS_PER_DAY;
end
end