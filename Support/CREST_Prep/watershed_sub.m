function watershed_sub(fileOut,siteShpOut,siteShp,outID,fileFDR,thDist)
%% description
% Generate basin mask from a given outlet to approximately thDist km
% All excluded sub-basins are controlled by a gauge contained in the
% siteShp
curFile = mfilename('fullpath');
[curDir,~,~]=fileparts(curFile);
[progDir,~,~]=fileparts(curDir);
addpath([progDir,'/MEX']);
addpath([progDir,'/geomorphology/common']);

GDALLoad();
[FDR,geoTrans,projFDR]=ReadRaster(fileFDR);
isGeographic=IsGeographic(projFDR,geoTrans);
[rows,cols]=size(FDR);
[xLoc,yLoc,projUSGS,siteID]=readShapeLoc(siteShp,1);
indOut=find(contains(siteID,outID));
sid=(1:length(xLoc))';
[XSite,YSite]=ProjTransform(projUSGS,projFDR,xLoc,yLoc);
[row,col]= Proj2RowCol(geoTrans, YSite, XSite,false);
rowOut=row(indOut);
colOut=col(indOut);
outOfBound=row>rows | row<1 | col>cols | col<1;
row(outOfBound)=[];
col(outOfBound)=[];
sid(outOfBound)=[];
siteIDmat=zeros(rows,cols);
ind=sub2ind([rows,cols],row,col);
siteIDmat(ind)=sid;
bEnd=false;
distMat=nan(rows,cols);
distMat(rowOut,colOut)=0;
sRow=rowOut;sCol=colOut;
basinMask=FDR>0;
IDUsed=[];
while ~bEnd
    [indUpstream,indDownstream]=findUpstream(sRow,sCol,basinMask,FDR);
    [rowUp,colUp]=ind2sub([rows,cols],indUpstream);
    fdrG=FDR(indUpstream);
    nextLen=GetNextLength(rowUp,colUp,fdrG,geoTrans,isGeographic);
    curLen=distMat(indDownstream)+nextLen;
    distMat(indUpstream)=curLen;
    indExceed=indUpstream(curLen>thDist*1000);
    indHasSite=indExceed(siteIDmat(indExceed)>0);
    idInMat=siteIDmat(indHasSite);
    IDUsed=[IDUsed;idInMat];
    indUpstream(ismember(indUpstream,indHasSite))=[];
    if isempty(indUpstream)
        bEnd=true;
    end
    [sRow,sCol]=ind2sub([rows,cols],indUpstream);
%     disp(min(curLen))
end
%% remove of the marginal of distMat(grids with zero distance in the marginal area)
maxCol=max(~isnan(distMat),[],1);
colLeft=find(maxCol,1,'first');
colRight=find(maxCol,1,'last');
maxRow=max(~isnan(distMat),[],2);
rowTop=find(maxRow,1,'first');
rowBtm=find(maxRow,1,'last');
[Ygeo,Xgeo]=RowCol2Proj(geoTrans,rowTop-0.5,colLeft-0.5);
geoTrans(1)=Xgeo;
geoTrans(4)=Ygeo;
distMat(:,colRight+1:end)=[];
distMat(:,1:colLeft-1)=[];
distMat(rowBtm+1:end,:)=[];
distMat(1:rowTop-1,:)=[];
GDT_Float=6;
NoDataValue=-1;
WriteRaster(fileOut,distMat,geoTrans,projFDR,GDT_Float,'GTiff',NoDataValue);
CreateShape(siteShpOut,'STCD',str2OTFType('OFTString'));
for iSite=1:length(IDUsed)
    AddAPoint(siteShpOut,xLoc(IDUsed(iSite)),yLoc(IDUsed(iSite)),'STCD',siteID{IDUsed(iSite)});
end
end