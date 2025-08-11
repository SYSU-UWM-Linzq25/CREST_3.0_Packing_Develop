function ExtractLakeTrib(strFDR,strLakeMask,xLeft,yTop,xRight,yBtm,xOut,yOut,dirOut)
%% input
% fdr: fdr map that covers all tribuberies
% lake: a lake mask denotes the lake region value|NaN=lake|overland
% xLeft-yBtm region in mapX and mapY that contains the river's tributaries
% (xOut, yOut)¡¡lake outlet
%%% mainbody
% crop all rasters to the rectangle limited by LT and RB
GDALLoad();
[~,~,~,geoTrans,proj]=RasterInfo(strFDR);
[geoTrans,r0,c0,rows,cols]=subsetgeoTrans(geoTrans,xLeft,yTop,xRight,yBtm);
%fdr
fdr=ReadRaster(strFDR,r0,c0,rows,cols);
basinMask=true(rows,cols);
% lake mask->proj and resolution of FDR
fileTemp=[dirOut,'temp.tif'];
fileBoundary=[dirOut,'boundary_taperized.tif'];
outBoundary=[dirOut,'out_taperized.tif'];
shpOut=[dirOut,'outlets.shp'];
basinOutRas=[dirOut,'tributaries.tif'];
ResampleAndClip(geoTrans,proj,cols,rows,strLakeMask,fileTemp,'GTiff',1);
lakeMask=ReadRaster(fileTemp);
lakeMask(lakeMask>0)=true;
lakeMask(lakeMask==0 |isnan(lakeMask))=false;
lakeMask=logical(lakeMask);
%% taper the lake region
% conceptually, a boundary cell belongs to the lake area as the inner cells
[rowOut,colOut]=Proj2RowCol(geoTrans,yOut,xOut);
hasLakeOut=true;
while hasLakeOut
    [row,col]=findBoundary(lakeMask);
    %% rule out the outlet for any modification
    indOut=row==rowOut & col==colOut;
    row(indOut)=[];
    col(indOut)=[];
   %% turn a boundary cell to overland if its next downstream cell is
    % overland
    ind=sub2ind([rows,cols],row,col);
    [nextRow,nextCol]=GetNextCellV(fdr(ind),row,col,basinMask);
    nextInd=sub2ind([rows,cols],nextRow,nextCol);
    erode=~lakeMask(nextInd);
    indErase=sub2ind([rows,cols],row(erode),col(erode));
    lakeMask(indErase)=false;
    
    %% turn a boundary cell's all 8-neighbouring cells to lake if it contains both inner lake and overland cells as tributaries.  
    [row,col]=findBoundary(lakeMask);
    ind=sub2ind([rows,cols],row,col);
    [indUpstream,indDownstream]=findUpstream(row,col,basinMask,fdr);
    isInLakeUpstream=lakeMask(indUpstream);
    indDownU=accumarray(indDownstream,double(isInLakeUpstream),[],@xor1d,[],true);
    [indDownU,~,isMixed]=find(indDownU);
    indDownMixed=indDownU(isMixed);
    toSwell=ismember(indDownstream,indDownMixed);
    swell=indUpstream(toSwell);
%     [rowMixed,colMixed]=ind2sub([rows,cols],indDownMixed);
%     [rowMixedAdj,colMixedAdj,~,~]=GetAdj(rowMixed,colMixed,8,basinMask);
%     swell=sub2ind([rows,cols],rowMixedAdj,colMixedAdj);
    lakeMask(swell)=true;
    %% if any changes are made, repeat the process
    if any(erode) || any (swell)
        hasLakeOut=true;
    else
        hasLakeOut=false;
    end
end
% [row,col]=findBoundary(lakeMask);
% ind=sub2ind([rows,cols],row,col);
boundaryMask=nan(rows,cols);
boundaryMask(ind)=1;
WriteRaster(fileBoundary,boundaryMask,geoTrans,proj,1,'GTiff',255);
%% find outlets on the boundary by removing those who only has inner upstream
% [nextRow,nextCol]=GetNextCellV(fdr(ind),row,col,basinMask);
% nextInd=sub2ind([rows,cols],nextRow,nextCol);
% flowAlongBound=ismember(ind,nextInd);

[indUpstream,indDownstream]=findUpstream(row,col,basinMask,fdr);
isInLakeUpstream=lakeMask(indUpstream);
indDownU=accumarray(indDownstream,double(isInLakeUpstream),[],@doubleany,[],true);
fromInner=find(indDownU);
flowAlongBound=ismember(ind,fromInner);
rowIn=row(~flowAlongBound);
colIn=col(~flowAlongBound);
outInd=sub2ind([rows,cols],rowIn,colIn);
inMask=nan(rows,cols);
inMask(outInd)=1;
WriteRaster(outBoundary,inMask,geoTrans,proj,1,'GTiff',255);
[yIn,xIn]=RowCol2Proj(geoTrans,rowIn,colIn);
%% watershed algorithm for each outlet
% create a shape file of these outlets
delete(shpOut);
CreateShape(shpOut,'OutID',str2OTFType('OFTReal'));
fid=fopen([dirOut,'outlets.prj'],'w+');
fprintf(fid,proj);
fclose(fid);
for i=1:length(colIn)
    AddAPoint(shpOut,xIn(i),yIn(i),'OutID',num2str(i));
end
segmentbasin(shpOut,strFDR,basinOutRas,xLeft,yTop,xRight,yBtm);
end
function [row,col]=findBoundary(mask)
[rows,cols]=size(mask);
[col,row]=meshgrid(1:cols,1:rows);
col=col(mask);
row=row(mask);
% ind=sub2ind([rows,cols],row,col);
dr=[1 1 1 0 0 -1 -1 -1];
dc=[0 -1 1 1 -1 1 0 -1];
isBoundary=false(length(col),1);
for i=1:length(dr)
    ind=sub2ind([rows,cols],row+dr(i),col+dc(i));
    isBoundary=isBoundary | (~mask(ind));
end
row=row(isBoundary);
col=col(isBoundary);
end
function res=xor1d(x)
if any(x) && any(~x)
    res=true;
else
    res=false;
end
res=double(res);
end
function res=doubleany(x)
res=double(any(x));
end