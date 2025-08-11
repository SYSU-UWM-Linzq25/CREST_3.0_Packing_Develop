function siteCorrection(shapeIn,areaField,unit,facRas,radius,facTol,shapeOut,xLeft,xRight,yTop,yBtm)
%% This function moves the designatd site to the "correct" stream based on drainage area matching.
% shapefile : A string that contains all sites to be processed
% facfile: the file name of the fac map
% radius: maximum distance in the maps unit
% facTol: fraction of drainage error tollerance
% shapeOut; output shape file
GDALLoad();
S = shaperead(shapeIn);
S([S.(areaField)]==-1 | [S.(areaField)]==0 | isnan([S.(areaField)]))=[];
n0=length(S);
switch unit
    case 'mi2'
        factor=0.38610;
    case 'km2'
        factor=1;
end
DASites=[S.(areaField)]'/factor;% mi^2 to km^2
nSites=length(S);
[~,~,projSites]=readShapeLoc(shapeIn,1);
[~,~,~,geoTransFAC,projFAC]=RasterInfo(facRas);
if exist('xLeft','var')==1
    [geoTransFAC,r0,c0,rows,cols]=subsetgeoTrans(geoTransFAC,xLeft,yTop,xRight,yBtm);
    FAC=ReadRaster(facRas,r0,c0,rows,cols);
else
    FAC=ReadRaster(facRas);
end

[rows,cols]=size(FAC);
[XSitesInFAC,YSitesInFAC]=ProjTransform(projSites,projFAC,[S.X]',[S.Y]'); 
[rowSites,colSites]= Proj2RowCol(geoTransFAC, YSitesInFAC,XSitesInFAC);
%% generate the neighboorhood area
nGrids=floor(radius/abs(geoTransFAC(2)));
xn=-nGrids:nGrids;
yn=xn;
[xn,yn]=meshgrid(xn,yn);
r=sqrt(xn.^2+yn.^2);
outOfRange=r>nGrids;
xn(outOfRange)=[];yn(outOfRange)=[];r(outOfRange)=[];
clear outOfRange
orgInd=find((xn==0)&(yn==0));
xn=xn(:);yn=yn(:);r=r(:);
nN=length(xn);
% xn=repmat(xn,[nSites,1]);yn=repmat(yn,[nSites,1]);r=repmat(r,[nSites,1]);
% rowSites=repmat(rowSites,[1,nN]);colSites=repmat(colSites,[1,nN]);
%% search for the nearst neighbor cell with the best matched drainage area
rMin=Inf*ones(nSites,1);
cErrMin=Inf*ones(nSites,1);
matchedCol=nan(nSites,1);
errorFAC=nan(nSites,1);
errorOrg=nan(nSites,1);
bGCS=IsGeographic(projFAC,geoTransFAC);
[~,gridArea]=RasterArea(FAC,geoTransFAC,bGCS);
if min(FAC(:))==0
    fac0=1;
else
    fac0=0;
end
for iN=1:nN
    row=rowSites+yn(iN);
    col=colSites+xn(iN);
    inMap=~(row<1 | row>rows |col<1 |col>cols);
    ind=sub2ind([rows,cols],row(inMap),col(inMap));
    iFac=(FAC(ind)+fac0).*gridArea(ind);%/1e6;
    errorFAC(~inMap)=Inf;
    errorFAC(inMap)=(iFac-DASites(inMap))./DASites(inMap);
    replace=(abs(errorFAC)<=facTol) & ...
        (...
         (rMin>r(iN)) | (rMin==r(iN) & abs(errorFAC)<abs(cErrMin))...
         );
    matchedCol(replace)=iN;
    rMin(replace)=r(iN);
    cErrMin(replace)=errorFAC(replace);
    if r(iN)==0
        errorOrg(inMap)=errorFAC(inMap);
    end
end
%% compute & update the corrected location for each site
maskFound=~isnan(matchedCol);
% remove the unmatched sites
S(~maskFound)=[];
cErrMin(~maskFound)=[];
errorOrg(~maskFound)=[];
rMin(~maskFound)=[];
rMin=rMin*abs(geoTransFAC(2));
% (row,col) of the corrected sites in the FAC map
rowCorrected=rowSites(maskFound)+yn(matchedCol(maskFound));
colCorrected=colSites(maskFound)+xn(matchedCol(maskFound));
% reproject the corrected sites back to the projection of the input shape file
[YCorrected,XCorrected]=RowCol2Proj(geoTransFAC,rowCorrected,colCorrected);
[XCorrected,YCorrected]=ProjTransform(projFAC,projSites,XCorrected,YCorrected); 
locCorrected=num2cell([XCorrected,YCorrected]);
[S.X,S.Y]=locCorrected{:};
error=num2cell([rMin,cErrMin,errorOrg]);
% add three new fields
[S.offset,S.cErr,S.oErr]=error{:};
%% statistics
n=length(S);
disp([num2str(n), '/', num2str(n0), ',', num2str(n/n0), 'is recovered']);
hist([S.cErr],50);
figure
hist(rMin);
xlabel('offset distance (m)')
figure
oErr=[S.oErr];
hist(oErr(-facTol<=oErr & oErr<=facTol),50);
figure
hist(oErr(oErr<-facTol),50);
figure
hist(oErr(oErr>facTol),50);
%% write the shape file
shapewrite(S,shapeOut);
end