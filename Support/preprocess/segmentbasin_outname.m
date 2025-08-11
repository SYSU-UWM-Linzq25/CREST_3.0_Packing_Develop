function segmentbasin_outname(ptShp,fdrRas,basinOutRas,separateFiles,xLeft,yTop,xRight,yBtm)
%% by Shen, Xinyi June, 2015
GDALLoad();
[~,~,~,geoTrans,projRas]=RasterInfo(fdrRas);
if exist('xLeft','var')% in case the image is too large
    [geoTrans,r0,c0,rows,cols]=subsetgeoTrans(geoTrans,xLeft,yTop,xRight,yBtm);
    fdr=ReadRaster(fdrRas,r0,c0,rows,cols);
else
    fdr=ReadRaster(fdrRas);
end

% if ischar(ptShp)
    [xLoc,yLoc,projOutlets,IDs]=readShapeLoc(ptShp,0);
%     nOutlets=length(xLoc);
    % fac=ReadRaster(facRas);
    [X2,Y2]=ProjTransform(projOutlets,projRas,xLoc,yLoc);  
    [row,col]= Proj2RowCol(geoTrans, Y2, X2);
% else
%     row=ptShp(:,1);
%     col=ptShp(:,2);
% end
nOutlets=length(row);
[ySize,xSize]=size(fdr);
id0=1;
if ~separateFiles
    mask=zeros(ySize,xSize);
    for iOut=1:nOutlets% loop over all sites to subset
        imask = extractbasin_s(fdr,row(iOut),col(iOut));
        if ~isnan(str2double(IDs{iOut}))
            if str2double(IDs{iOut})==0
                mask(logical(imask))=str2double(IDs{iOut})+1;
            else
                mask(logical(imask))=str2double(IDs{iOut});
            end
        else
            mask(logical(imask))=id0;
            id0=id0+1;
        end
    end
    maxCol=max(mask>0,[],1);
    colLeft=find(maxCol,1,'first');
    colRight=find(maxCol,1,'last');
    maxRow=max(mask>0,[],2);
    rowTop=find(maxRow,1,'first');
    rowBtm=find(maxRow,1,'last');
    [Ygeo,Xgeo]=RowCol2Proj(geoTrans,rowTop-0.5,colLeft-0.5);
    geoTrans(1)=Xgeo;
    geoTrans(4)=Ygeo;
    mask(:,colRight+1:end)=[];
    mask(:,1:colLeft-1)=[];
    mask(rowBtm+1:end,:)=[];
    mask(1:rowTop-1,:)=[];
    GDT_Int=5;
    NoDataValue=0;
    mask(~mask)=NaN;
    WriteRaster(basinOutRas,mask,geoTrans,projRas,GDT_Int,'GTiff',NoDataValue);
else
    iGeoTrans=zeros(6,1);
    iGeoTrans(2)=geoTrans(2);
    iGeoTrans(3)=geoTrans(3);
    iGeoTrans(5)=geoTrans(5);
    iGeoTrans(6)=geoTrans(6);
    for iOut=1:nOutlets% loop over all sites to subset  
        iBasinOutRas=[basinOutRas,'_',IDs{iOut},'.tif'];
        imask = extractbasin_s(fdr,row(iOut),col(iOut));
        maxCol=max(imask>0,[],1);
        colLeft=find(maxCol,1,'first');
        colRight=find(maxCol,1,'last');
        maxRow=max(imask>0,[],2);
        rowTop=find(maxRow,1,'first');
        rowBtm=find(maxRow,1,'last');
        [Ygeo,Xgeo]=RowCol2Proj(geoTrans,rowTop-0.5,colLeft-0.5);
        iGeoTrans(1)=Xgeo;
        iGeoTrans(4)=Ygeo;
        imask(:,colRight+1:end)=[];
        imask(:,1:colLeft-1)=[];
        imask(rowBtm+1:end,:)=[];
        imask(1:rowTop-1,:)=[];
        GDT_Byte=1;
        NoDataValue=255;
        imask(~imask)=NaN;
        WriteRaster(iBasinOutRas,double(imask),iGeoTrans,projRas,GDT_Byte,'GTiff',NoDataValue);
    end
end
end