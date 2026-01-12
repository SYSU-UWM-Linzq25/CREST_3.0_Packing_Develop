classdef RasterVariables<handle
    methods(Access = public,Sealed=true)
        function obj=RasterVariables(geoTrans,spatialRef)
            if nargin==0
                disp('not initialized');
                return;
            end
            obj.spatialRef=spatialRef;
            obj.geoTrans=geoTrans;
            obj.bGCS=IsGeographic(obj.spatialRef,obj.geoTrans);
            OS=computer;
            if strcmpi(OS,'PCWIN64')
                obj.pathSplitor='\';
            elseif strcmpi(OS,'GLNXA64')
                obj.pathSplitor='/';
            end
        end
        function var = Initialize(obj, nLayers, rowsize, colsize)
            % the function must be called after the basinMask has been obtained
            % For Part load - Aug 30th 2025 - Linzq25
            % Extended Initialize function: support subgrid initialization
            % Usage:
            %   obj.Initialize() → full size 2D
            %   obj.Initialize(nLayers) → full size 3D
            %   obj.Initialize([], rows, cols) → subgrid 2D
            %   obj.Initialize(nLayers, rows, cols) → subgrid 3D
            if nargin == 1  % Only obj
                [rows, cols] = size(obj.basinMask);
                var = zeros(rows, cols);
                var(~obj.basinMask) = NaN;
            elseif nargin == 2  % obj + nLayers
                [rows, cols] = size(obj.basinMask);
                var = zeros(rows, cols, nLayers);
            elseif nargin == 4  % subgrid
                if isempty(nLayers)
                    var = zeros(rowsize, colsize);  % 2D tile
                else
                    var = zeros(rowsize, colsize, nLayers);  % 3D tile
                end
            else
                error('Invalid usage of Initialize().');
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
        pathSplitor;
    end
    methods(Abstract,Static)
        fileNames = GenerateFileNames(obj,dirFolder)
    end
end