classdef RasterVariables<handle
    methods(Access = public,Sealed=true)
        function var=Initialize(obj,nLayers)
            % the function must be called after the basinMask has been
            % obtained
            [rows,columns]=size(obj.basinMask);
            if nargin==1
                var=zeros(rows,columns);
                var(~obj.basinMask)=NaN;
            else
                var=zeros(rows,columns,nLayers);
            end
        end
        function [ind,bInBasin]=sub2indInBasin(obj,matRow,matCol)
            % ind: one dimensional indices that are within the basin
            % bInBasin: logical vector that indicates whether (matRow,matCol) is within the basin
            bInBasin=InRectangle(obj,matRow,matCol);
            ind=zeros(length(matRow),1);
            ind(bInBasin)=sub2ind(size(obj.basinMask),matRow(bInBasin),matCol(bInBasin));
%             indexOut=obj.basinMask(ind);
%             ind(~indexOut)=[];
            ind(bInBasin)=ind(bInBasin).*obj.basinMask(ind(bInBasin));
            bInBasin(bInBasin)=ind(bInBasin)>0;
            ind(~bInBasin)=NaN;
        end
        function index=InRectangle(obj,matRow,matCol)
            [rows,columns]=size(obj.DEM);
            index=logical((matRow<=rows).*(matRow>0).*(matCol<=columns).*(matCol>0));
        end
        
        function SaveRaster(obj,mat,fileGeoTif)
%             geotiffwrite(fileGeoTif,mat,obj.geo);
            GDT_Float32=6;
            WriteRaster(fileGeoTif,mat,obj.geoTrans,obj.spatialRef,GDT_Float32,'GTiff',-9999);
        end
    end
    methods(Static=true,Access=public)
        [value,bDistributed]=readVarInfo(gfileID,keywordType,...
                keywordVar,commentSymbol,pDir,...
                keywordUseExt,keywordExtPath,geoTrans,proj,basinMask);
        value=ReadAKeyword(gfileID,keyword,commentSymbol);
        function bRes=IsGCS(refMat)
            if(refMat(2,1)<2)
                bRes=true;
            else
                bRes=false;
            end
        end
    end
    properties(Access=public)
        basinMask;%the logical index matrix of valid data elements
        spatialRef;%OsGeo.OGR.SpatialReference
        geoTrans; % geographic transformation coefficients. Used to convert(r,c) to (mapX,mapY) or(lat lon)
        bGCS % indicate whether the projection of the basic data is gcs or PCS
%         proj;% projection info if has
    end
    methods(Abstract,Static)
        fileNames = GenerateFileNames(obj,dirFolder)
    end
end