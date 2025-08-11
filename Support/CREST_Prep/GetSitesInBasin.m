function [siteNo,lat,lon,nRow,nCol,bottom,left,res]=GetSitesInBasin(site_shp,streamRas,basinRas)
%% export the streamflow(discharge) data in (m^3/s) to the observation format of CREST
%% input
% site_shp      : (cell array) name of the shape file that 
%                 contains the corrected sites location
% streamflowData: the excel of daily discharge
% streamRas     : the stream raster
% basinRas      : the basin raster 
siteNo=[];
lat=[];
lon=[];
nFile=length(site_shp);
for i=1:nFile
    sitesRec=shaperead(site_shp{i});
    siteNo=[siteNo;[sitesRec.STCD]'];
    lat=[lat;[sitesRec.Y]'];
    lon=[lon;[sitesRec.X]'];
end
[streamZ,streamR]=ReadAscii(streamRas);
[basinZ,basinR,bottom,left,res]=ReadAscii(basinRas);
[nRow,nCol]=size(basinZ);
bInBasin = ltln2val(basinZ, basinR, lat, lon, 'nearest');
bInStream = ltln2val(streamZ, streamR, lat, lon, 'nearest');
bInBasin(isnan(bInBasin))=0;
bInStream(isnan(bInStream))=0;
indexInvalid=bInBasin~=bInStream;
errorSites=siteNo(indexInvalid);
if sum(indexInvalid)~=0
    for i=1:length(errorSites)
        sprintf('error in %d \t',errorSites(i))
    end
%     return;
end
bInStream=logical(bInStream);
lat=lat(bInStream);
lon=lon(bInStream);
siteNo=siteNo(bInStream);
end
