classdef HydroSites<handle
    properties
        STCD;
        indexOutlets;% STCD index of outlets used to compute the statistics
        nSites;
        row;col;
        runoff;
        noObserv;
        startDate;
        warmupDate;
        endDate;
        nTimeSteps;
        timeStep;
        nPeriods;
        griddedInd;
        nGObs;% number of griddedObservation
        nGCells;
        GVar;%  matrices of observation
        meanSimGVar;
        dateRefSto;% currently stored date number
        dateRefInter;% date interval 
        nAgger;% number of aggregated forcing varible (matrices)
        sumDiff2;% $$ \Sigma(Var-Var_{Obs})^2$
        sumObs2;% $$ \Sigma(Var_{Obs}).^2$
        sumObs;%$$ \Sigma(Var_{Obs}) $
        sumSim;
        nObs;% number of observations
        datefmtInt;% internal dateformat of observation data
        datefmtExt;% external dateformat of observation data
        dirRefExt;% external directory storing observation data
        dirRefInt;% internal directory storing observation data
        dateRefConv;
        fmtExt;% extension of external observation
        maskRef;
        %% statistics
        NSCE;
        Bias;
        CC;
        started;
    end
    methods
        function obj=HydroSites(shapefile,geoTransTar,spatialRefTar,...
                noObserv,nTimeSteps,startDate,endDate,numOfLoaded,...
                timeStep,warmupDate,...
                cDir,griddedInd,coreNo,nCores)
            [xLoc_shp,yLoc_shp,spatialRef,STCD_shp]=readShapeLoc(shapefile,0);
            % Define the number of points in the shapefile
            numPoints = numel(xLoc_shp);
            % Calculate the chunk size for each core
            chunkSize = floor(numPoints / nCores);
            % Calculate the remainder points
            remainder = rem(numPoints, nCores);
            % Calculate the starting and ending indices for the current worker (coreNo)
            startIdx = (coreNo - 1) * chunkSize + 1 + min(coreNo - 1, remainder);
            endIdx = coreNo * chunkSize + min(coreNo, remainder);
            % Assign the working range for the current worker
            xLoc = xLoc_shp(startIdx:endIdx);
            yLoc = yLoc_shp(startIdx:endIdx);
            obj.STCD = STCD_shp(startIdx:endIdx);
            % original code
            [XTar,YTar]=ProjTransform(spatialRef,spatialRefTar,xLoc,yLoc);
            [obj.row,obj.col]= Proj2RowCol(geoTransTar, YTar, XTar);  
            obj.nSites=length(obj.STCD);
            obj.noObserv=noObserv;
            obj.nTimeSteps=nTimeSteps;
            obj.startDate=startDate;
            obj.nPeriods=numOfLoaded;
            obj.endDate=endDate;
            obj.timeStep=timeStep;
            obj.warmupDate=warmupDate;
            cFile=strcat(cDir,'calibrations.txt');
            obj.griddedInd=griddedInd;
            
            cFileID = fopen(cFile);
            commentSymbol='#'; 
            obj.nGObs=str2double(RasterVariables.ReadAKeyword(cFileID,'nGVar',commentSymbol));
            obj.nGCells=zeros(obj.nGObs,1);
            obj.fmtExt=cell(obj.nGObs,1);
            obj.datefmtExt=cell(obj.nGObs,1);
            obj.datefmtInt=cell(obj.nGObs,1);
            obj.dateRefConv=cell(obj.nGObs,1);
            obj.dateRefSto=zeros(obj.nGObs,1);
            obj.dateRefInter=zeros(obj.nGObs,1);
            obj.dirRefInt=cell(obj.nGObs,1);
            obj.dirRefExt=cell(obj.nGObs,1);
            obj.sumDiff2=cell(obj.nGObs,1);
            obj.sumObs2=cell(obj.nGObs,1);
            obj.sumObs=cell(obj.nGObs,1);
            obj.GVar=cell(obj.nGObs,1);
            obj.nAgger=zeros(obj.nGObs,1);
            obj.nObs=cell(obj.nGObs,1);
            obj.NSCE=cell(obj.nGObs,1);
            obj.CC=cell(obj.nGObs,1);
            obj.Bias=cell(obj.nGObs,1);
            for iVar=1:obj.nGObs
                keyword=['TarVar' num2str(iVar)];
                varName=RasterVariables.ReadAKeyword(cFileID,keyword,commentSymbol);
                keyword=[varName 'Format'];
                obj.fmtExt{iVar}=RasterVariables.ReadAKeyword(cFileID,keyword,commentSymbol);
                keyword=[varName 'DateFormatExt'];
                obj.datefmtExt{iVar}=RasterVariables.ReadAKeyword(cFileID,keyword,commentSymbol);
                keyword=[varName 'DateConv'];
                obj.dateRefConv{iVar}=RasterVariables.ReadAKeyword(cFileID,keyword,commentSymbol);
                keyword=[varName 'DateInterval'];
                strDateInter=RasterVariables.ReadAKeyword(cFileID,keyword,commentSymbol);
                obj.dateRefInter(iVar)=GlobalParameters.CalTimeInterval(strDateInter,obj.datefmtExt{iVar});
                keyword=[varName 'PathInt'];
                obj.dirRefInt{iVar}=RasterVariables.ReadAKeyword(cFileID,keyword,commentSymbol);
                idirRefInt=obj.dirRefInt{iVar};
                if ~(strcmpi(idirRefInt(end),'\') || strcmpi(idirRefInt(end),'/'))
                    idirRefInt=fileparts(idirRefInt);
                end
                mkdir(idirRefInt);
                keyword=[varName 'PathExt'];
                obj.dirRefExt{iVar}=RasterVariables.ReadAKeyword(cFileID,keyword,commentSymbol);
                keyword=[varName 'DateFormatInt'];
                obj.datefmtInt{iVar}=RasterVariables.ReadAKeyword(cFileID,keyword,commentSymbol);
                obj.nGCells(iVar)=length(obj.griddedInd);
            end
            fclose(cFileID);
        end
        ImportObservation2(this,eventMode,dirObs,FEDB,obsFormat,STCDOutlets);
        eval(this,fileHydro,dateCur,simGVar,mode,iPeriod,isFinal,node,nNodes);
        reset(this)
    end
    methods (Access=private)
         function [fileObs]=GenerateFileNames(obj,dirObs)
            fileObs=cell(obj.nSites,1);
            for i=1:obj.nSites;
                if ischar(obj.STCD{i})
                    fileObs{i}=strcat(dirObs,obj.STCD{i},'_obs.csv');
                else
                    fileObs{i}=strcat(dirObs,num2str(obj.STCD{i}),'_obs.csv');
                end
            end
         end
        saveGraph(this,fileHydro,dateCur);
    end
    methods (Static)
        function [xLoc,yLoc,spatialRef]=GetOutlet(shapefile,outletID)
            [xLoc,yLoc,spatialRef]=readShapeLoc(shapefile,0,outletID);
        end
        [sh,eh,shAP,ehAP]=ReadFloodEvents(FEDB,STCD,fmt);% added in Jan, 2016
        vpi=maxInd(val);
    end
end

