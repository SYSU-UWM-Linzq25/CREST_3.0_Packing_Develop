function DEMapGen(this,fdrFile,demFile,streamFile,ratioCO)
GDTFloat=6;
GDTUInt=5;
DEM=ReadRaster(demFile);
[FDR,geoTrans,proj]=ReadRaster(fdrFile);
stream=ReadRaster(streamFile);
basinMask=FDR>0;
isGeo=IsGeographic(proj,geoTrans);
[rows,cols]=size(FDR);
this.elevMap=nan(rows,cols);
this.distMap=nan(rows,cols);
this.outletMap=nan(rows,cols);
rowAll=[this.nodes.row];
colAll=[this.nodes.col];
indAll=sub2ind([rows,cols],rowAll,colAll);

mapAllNodes=false(rows,cols);
mapAllNodes(indAll)=true;
rowOuts=[this.outlets.row];
colOuts=[this.outlets.col];
%% initialize the most downstream outlets
indOut=sub2ind([rows,cols],rowOuts,colOuts);
this.elevMap(indOut)=0;
this.distMap(indOut)=0;
this.outletMap(indOut)=0;%set the the index of all outlets to 0. THe index of upstream nodes are set to their parents.
%% iteratively go upstream to fill the whole map
gRow=rowOuts;
gCol=colOuts;
while ~isempty(gRow)
    [indUpstream,indDownstream]=findUpstream(gRow,gCol,basinMask,FDR);
    maskReset=mapAllNodes(indDownstream);
    elevUpstream=DEM(indUpstream);
    elevDownstream=DEM(indDownstream);
    [gRow,gCol]=ind2sub([rows,cols],indUpstream);
    nextLen=GetNextLength(gRow,gCol,FDR(indUpstream),geoTrans,isGeo);
    isChannel=logical(stream(indUpstream));
    nextLen(isChannel)=nextLen(isChannel)/ratioCO;
    % if the downstream point is an outlet, reset the elevation difference
    % to the difference to the downstream point
    this.elevMap(indUpstream(maskReset))=elevUpstream(maskReset)-elevDownstream(maskReset);
    this.distMap(indUpstream(maskReset))=nextLen(maskReset);
    this.outletMap(indUpstream(maskReset))=indDownstream(maskReset);
    % otherwise, accumulate the elevation difference to the last outlet
    this.elevMap(indUpstream(~maskReset))=elevUpstream(~maskReset)-elevDownstream(~maskReset)+...
    this.elevMap(indDownstream(~maskReset));
    this.distMap(indUpstream(~maskReset))=nextLen(~maskReset)+this.distMap(indDownstream(~maskReset));
    this.outletMap(indUpstream(~maskReset))=this.outletMap(indDownstream(~maskReset));
end
% this.elevMap(this.elevMap<0)=0; we allow negative elevation difference in before saving ED grids
WriteRaster(this.fileElevMap,this.elevMap,geoTrans,proj,GDTFloat,'GTiff',-9999);
WriteRaster(this.fileDistMap,this.distMap,geoTrans,proj,GDTFloat,'GTiff',-9999);
WriteRaster(this.fileOutletMap,this.outletMap,geoTrans,proj,GDTUInt,'GTiff',-9999);
end