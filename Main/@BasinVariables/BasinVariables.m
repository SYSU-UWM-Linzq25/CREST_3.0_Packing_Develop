classdef BasinVariables<RasterVariables
    properties
        DEM;% DEM matrix
        FDR;% flow direction matrix
        FAC;% flow accumulation matrix
        stream;% stream matrix
        lake;% logical matrix:1 lake| 0 not lake
        
        GM;% avarage height difference
        heightNextToOutlet;% height next to the outlet
        lat; %latitude of each grids
        LenSN;% height of a cell in meters
        LenEW;% matrix of width each cells in meter 
        LenCross;% diagonal length of the cell
        slope;% slope matrix from each to the next cell
        gridArea;%area matrix of each grid
        nextRow;%next row matrix of each grid 
        nextCol;%next column matrix of each grid
        nextLen;%next length matrix of each grid
        nextTimeS;%the time that water needs to run from the current cell to the next overland (in the time step unit)
        nextTimeI;%the time that water needs to run from the current cell to the next underground (in the time step unit)
        % routing variables
        % A:    the furthest cell water can reach from the current cell within one timestep
        % B:    the next cell of A
        % FracA: time fraction of 1-FracB
        % FracB: time fraction of (dt-t(current to A))/t(A to B)
        % S:  surface flow
        % I:  interflow
        % PerA and PerB are used to represent the partition of runoff that stay in A and B respectively
        SRowA;SColA;SFracA;
        SRowB;SColB;SFracB;
        IRowA;IColA;IFracA;
        IRowB;IColB;IFracB;
        % passed through index of Runoff
        RSPassedRow;RSPassedCol;RSStartedRow;RSStartedCol;
        RIPassedRow;RIPassedCol;RIStartedRow;RIStartedCol;
        % geolocation of the observation sites
        STCD;
        rowOutlet;
        colOutlet;
        indexOutlet;
        masks;
        maskEnt;
        multiCoreMasks;
        nodeIndRef;% unique 1d-index of the reference
        nodeInd;% repeated 1d-index
        pathNodeMask;
    end
    properties(Access=private)
        rTimeUnit;
    end
    methods
        function obj=BasinVariables(basicDir,basicFmt,timeMark,useExt,shapefile,outletName,demExt,fdrExt,facExt,streamExt,...
                taskType,node,numOfNodes,resPathNodeMasks)
            [fileDEM,fileFDR,fileFAC,fileStream,fileLake,fileMask,fileGM,fileRefMask]=...
                BasinVariables.GenerateFileNames(basicDir,basicFmt);
            [~,~,~,geoTrans,proj]=RasterInfo(fileDEM);
            obj=obj@RasterVariables(geoTrans,proj);
            obj.pathNodeMask=resPathNodeMasks;
            switch timeMark
                case 'd'
                    obj.rTimeUnit=1/24;
                case 'h'
                    obj.rTimeUnit=1;
                case 'u'
                    obj.rTimeUnit=60;
            end
            disp('reading geographic data...')
            if useExt
                [xLocOut,yLocOut,srOutlet]=HydroSites.GetOutlet(shapefile,outletName);
                BasinVariables.GetBasinMaskFrmGlobal(xLocOut,yLocOut,srOutlet,demExt,fdrExt,facExt,streamExt,fileMask,fileDEM,fileFDR,fileFAC,fileStream,'GTiff');
            end
            obj.DEM=ReadRaster(fileDEM);
            obj.FDR=ReadRaster(fileFDR);
            obj.FAC=ReadRaster(fileFAC);
            obj.ReadGM(fileGM);
            if ~isempty(fileLake)
                disp('loading lake area...');
                obj.lake=ReadRaster(fileLake);
            else
                obj.lake=zeros(size(obj.DEM));
                obj.lake(isnan(obj.DEM))=NaN;
            end
            disp('identifying channel cells...')
            obj.stream=ReadRaster(fileStream);
            obj.stream(isnan(obj.stream))=0;
            obj.stream=logical(obj.stream);
            disp('generating basin mask...');
            obj.GetBasinMask();            
            switch taskType
                case 'ImportForc'
                    bRouting=false;
                    obj.maskEnt=obj.basinMask;
                    disp('import forcing data...')
                case 'LandSurf'
                    obj.GetNodeBasinMask(fileRefMask,node,numOfNodes);
                    bRouting=false;
                    disp('generating grid area...')
                case 'Mosaic'
                    obj.ReadMultiCoreBasinMasks(numOfNodes);
                    bRouting=true;
                    disp('generating routing map...')
                case 'Routing'
                    bRouting=true;
            end
            obj.AssignNextGroup(bRouting);
        end 
        CalSlope(obj,mode,rowOutlet,colOutlet);
        GetSubMasks(obj,outRow,outCol,outName,maskDir);
        ReadMultiCoreBasinMasks(obj,numOfNodes);
        [row,col]=GetStreamRowAndCol(obj);
        RunoffAndRoutePre(obj,timeStep,coeM,expM,coeR,coeS,RunoffRows,RunofCols,hasRiverInterflow);
    end
    methods (Access= private)
        AssignNextGroup(obj,bRouting);
        function CalSlopeXXW(obj)
            [rows,columns]=size(obj.DEM);
            index=obj.InRectangle(obj.nextRow,obj.nextCol);
            index=logical(index.*obj.basinMask);
            obj.slope=obj.Initialize();
            
            demNext=obj.Initialize();
            demNext(index)=obj.DEM(sub2ind([rows,columns],obj.nextRow(index),obj.nextCol(index)));            
            demNext(isnan(demNext))=-9999;
            indexValid=logical((obj.DEM>demNext).*obj.basinMask);
            indexInvalid=logical((~indexValid).*obj.basinMask);
            obj.slope(indexValid)=(obj.DEM(indexValid)-demNext(indexValid))./obj.nextLen(indexValid);
            
            obj.slope(indexInvalid)=obj.CalSlopeNoData(indexInvalid);
            obj.slope(obj.slope<0)=-obj.slope(obj.slope<0);
            obj.slope(abs(obj.slope)<1e-6)=1e-6;
        end
        CalSlopeTiger(obj);
        CalNextTime(obj,coeM,expM,coeR,coeS,hasRiverInterflow);
        [toRowA,toColA,toPerA,toRowB,toColB,toPerB,...
            RPassedRow,RPassedCol,RStartedRow,RStartedCol]=RouteTreat(obj,timeStep,nextTimeX,RSitesRow,RSitesCol);
        z_adj=FillAdjDEM(obj,r_adj,c_adj,r,c);
        slope=CalSlopeNoData(obj,indexNodata);
        ReadGM(obj,fileName);
        GetBasinMask(obj);
        GetNodeBasinMask(obj,fileRefMask,node,nodeNum);
    end
    
    methods(Static)
        function [fileDEM,fileFDR,fileFAC,fileStream,fileLake,fileMask,fileGM,fileRefMask]=GenerateFileNames(basicDir,basicFmt)
            fileDEM=strcat(basicDir,'dem',basicFmt);
            fileFDR=strcat(basicDir,'fdr',basicFmt);
            fileFAC=strcat(basicDir,'fac',basicFmt);
            fileStream=strcat(basicDir,'stream',basicFmt);
            fileLake=strcat(basicDir,'lake',basicFmt);
            if exist(fileLake,'file')~=2
                disp('No lake exist since a lake mask is not provided.')
                fileLake='';
            end
            fileMask=strcat(basicDir,'mask',basicFmt);
            fileGM=strcat(basicDir,'slope.def');
            fileRefMask=[basicDir,'refMask.tif'];
        end
        GetBasinMaskFrmGlobal(xLocOut,yLocOut,srOutlet,DEMExt,FDRExt,FACExt,streamExt,fileMask,fileDEM,fileFDR,fileFAC,fileStream,outFormat);
    end
    % Release memory - Aug 28th, 2025, Linzq25
    methods
        function releaseMemory(obj)
            mc = metaclass(obj);
            fprintf('Releasing memory for object of class: %s\n', class(obj));
            for k = 1:length(mc.PropertyList)
                prop = mc.PropertyList(k);
                if ~prop.Constant && ~prop.Dependent && prop.SetAccess == "public"
                    propName = prop.Name;
                    try
                        obj.(propName) = [];
                        fprintf('  Cleared property: %s\n', propName);
                    catch ME
                        warning('  Failed to clear property: %s (%s)', propName, ME.message);
                    end
                end
            end
        end
    end
end