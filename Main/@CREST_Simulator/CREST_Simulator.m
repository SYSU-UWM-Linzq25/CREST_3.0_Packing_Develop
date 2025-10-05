                 %% Hydrologic process simulator(v2.1)
% writen by Shen, Xinyi June, 2014 
% contact:xinyi.shen@uconn.edu
% 1) updated in July, 2019, Shen, Xinyi to add the forecast module
% updated in April, 2015 -Shen, Xinyi DirectRunoffGen
classdef CREST_Simulator<matlab.mixin.Copyable
    properties
        basicVar;
        modelPar;
        stateVar;
        forcingVar;
        globalVar;
    end
    properties(Access=private)
        %% medium of the atmosphere-soil structure
         canopy;
         snowpack;
         soilSurf;
         dt; % time step in hour
    end
    properties(Access=private)% it should be in mind that variables in this class
        %is not in the form of a raster, but in vectors
        %% all variables in this section are vectors 
        % that contains the (~noData) values 
        % extracted from modelPar 
        % For the efficiency processing, vectors copied from model par will be 
        % initialized for only once.
        KS;KI
        %%  all variables in this section are vectors 
        % that contains the (~noData) values 
        % extracted from stateVar and forcingVar
        % These vectors must be updated back and forth at each time step
%         excS;excI;
        rain; % liquid rainfall (mm/timestep)
        snow; % solid snow fall (mm/timestep)
        shortwave;
        longwave;
        pressure % (Pa) atmospheric pressure
        airDens;% airDensity (kg/m^3);
        eAct; % (Pa) actual vapor pressure
        VPD; % (Pa) vapor pressure deficit
        LAI;
        Tair; % (^oC) Air Temperature
        wind; % (m/s) wind speed
        EAct; % actual ET (mm/timestep)
        SS0;SI0;RS;RI;
        rainBare; %/throguh fall MODIFIED
        actTranspir; %/transpiration in soil
        runoff;
        PET; % potential ET (mm/timestep)
%         drip% test
%         basinInd;% n*2 matrix stores the starting and ending indices of the basin cells
%         localInd;% n*2 matrix stores the starting and ending of consecutive local indices 
        numOfImpossibleT;
        numOfNotConv;
        % please refer the comment in BasinVariables to obtain the
        % definition of S/IFracA/B
        % S/IIndexA/B refers to the one-dimensional index of the downstream
        % targeting cell uS/IIndexA/B refers to the unique targeting cell
        % it should be noted that a number of elements in S/IIndexA/B are
        % nonunique because multiple cells can be routed to one downstream
        % cell.

        NaNIndex;%substitution of NaN cell indices
        SIndexA;SFracA;uSIndexA;SIndexAValid;
        SIndexB;SFracB;uSIndexB;SIndexBValid;
        IIndexA;IFracA;uIIndexA;IIndexAValid;
        IIndexB;IFracB;uIIndexB;IIndexBValid;
        % runoff indices
        RSPassedIndex;uRSPassedIndex;RSStartedIndex;
        RIPassedIndex;uRIPassedIndex;RIStartedIndex;
        
        gridArea;
        SgridAreaA;SgridAreaB;IgridAreaA;IgridAreaB;
        nCells;% count of cells in basin
        rTimeUnit% scaling ratio caused by time unit
        oldResFile;% result file of the lastbunch
        coreDir;
  
        maskRoute;% mask for routing purpose
    end
    methods(Access=public)
        function obj=CREST_Simulator(modelPar,basicVar,sVar,forcingVar,globalVar)            
            obj.modelPar=modelPar;
            obj.stateVar=sVar;
            obj.forcingVar=forcingVar;
            obj.basicVar=basicVar;
            obj.globalVar=globalVar;
%             obj.genBasinInd(obj.stateVar.basinMask)
            if ~strcmpi(obj.globalVar.taskType,'Routing')
                switch obj.globalVar.timeMarkLS
                    case 'd'
                        obj.rTimeUnit=1/24;
                    case 'h'
                        obj.rTimeUnit=1;

                    case 'u'
                        obj.rTimeUnit=60;
                end
                obj.dt=globalVar.timeStepInMLS/obj.rTimeUnit;
            else
                switch obj.globalVar.timeMarkRoute
                    case 'd'
                        obj.rTimeUnit=1/24;
                    case 'h'
                        obj.rTimeUnit=1;

                    case 'u'
                        obj.rTimeUnit=60;
                end
                obj.dt=globalVar.timeStepInMRoute/obj.rTimeUnit;
            end
%%            1)
            if obj.forcingVar.isFore
                obj.globalVar.resPathInit=ForcingVariables.tagPathDT(obj.globalVar.resPathInit,...
                    obj.forcingVar.dateStartFore);
                obj.globalVar.resPathEx=ForcingVariables.tagPathDT(obj.globalVar.resPathEx,...
                    obj.forcingVar.dateStartFore);
                obj.globalVar.resPathMosaic=ForcingVariables.tagPathDT(obj.globalVar.resPathMosaic,...
                    obj.forcingVar.dateStartFore);
                obj.globalVar.resPathAgger=ForcingVariables.tagPathDT(obj.globalVar.resPathAgger,...
                    obj.forcingVar.dateStartFore);
                obj.globalVar.resPathVal=ForcingVariables.tagPathDT(obj.globalVar.resPathVal,...
                    obj.forcingVar.dateStartFore);
            end
            if strcmpi(obj.globalVar.taskType,'LandSurf')
                disp(['creating' obj.globalVar.resPathInit '...'])
                mkdir(obj.globalVar.resPathInit);
                mkdir(obj.globalVar.resPathVal);
            end
            if strcmpi(obj.globalVar.taskType,'Routing')
                mkdir(obj.globalVar.resPathEx);
            end
            if strcmpi(obj.globalVar.taskType,'Mosaic') 
                mkdir(obj.globalVar.resPathMosaic);
                mkdir(obj.globalVar.resPathAgger);
            end
            
%% end 1)            
        end
%         [NSCE,tElapse]=Simulate(this,coreNo,x0,keywords);
        Simulate_LandSurf(this,coreNo,nCores,x0,keywords);
        [NSCE,tElapse]=Simulate_Routing(this,x0,keywords);
        mosaic(this,core,nCores);
    end
    methods(Access=protected)
         function cpObj = copyElement(obj)
            % Make a shallow copy of all four properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
         end
    end
    methods(Access=private)
        [fileLocal,fileExport]=FlushToRes(this,dirLocMosaicOut,varListInFile,varListInMem);
        ModelParInit(this,node,nNodes,x0,keywords);
        partRainAndSnow(this,Tair,prec,MIN_RAIN_TEMP,MAX_SNOW_TEMP);
        calVP(this);
        function [XIndexY,uXIndexY,XIndexValidY]=ComputeRoutingIndices(obj,XRowY,XColY)
            %% intput variables
            % (XRowY,XColY) the (row,column) of the downstream cell (or the next)
            %% output variables
            % *** variables below this line is of the same size as the dimension of the downstream cells ***
            % XIndexY: one-dimensional index of the downstream cell(or the next) (routing target)
            % uXIndexY: unique value of XIndexY
            % *** variables below this line is of the same size as the same dimension of the upstream cells ***
            % XIndexValid: logical indices of the valid upstream cells(the invalid cells contribute only to the cell out of the basin after one timestep)
            [XIndexY,XIndexValidY]=obj.basicVar.sub2indInBasin(XRowY,XColY);
%             sub2ind(size(obj.stateVar.basinMask),XRowY,XColY);
%             XIndexValidY=~isnan(XIndexY);%obj.basicVar.basinMask(XIndexY);
%             XIndexValidY(XIndexValidY)=obj.stateVar.basinMask(XIndexY(XIndexValidY));
            XIndexY=XIndexY(XIndexValidY);
            uXIndexY=unique(XIndexY);
            %% some index can be further cut off because they are out of the basin
        end
        genBasinInd(this,basinMask);
        GetForcing(this);
        NLDASAdj(this);
        ImportLandSurfRes(this,nCoresLS,varListInFile);
        LoadDirectRunoff(this);
        LandSurfProc(this,node,nNodes);
        error=OutputVar(this,checkMassBal,core,nCores)
        [T,nNotConv,it]=solveLandProc(this,T,mask,snowType,iceSurf,icePack,TWThru,rainThru,shortOverIn,shortUnder);
        rainBare=updateAllMedium(this,Tfoliage,Tcanopy,TSnow,Tsoil,T1Soil,...
            vaporFluxSub_can,actEvap_can,actEvapGrnd_can,actTranspir_can,energyPhaseChange_can,...
            dCCSurf,dCCPack,refrozenIcePack,energyPhaseChange_pack,vaporMassEvap_pack,vaporMassSub_pack,...
            vaporFluxEvapVeg,vaporGrndSoil,vaporTransSoil);
        WaterBudgetUpdate(this);
        StateVarUpdate(this);
        genParMask(this);
        [varListInFile,varListInMem]=genVarList(this);% newly added function for the monthly file
        DownstreamRoute(this);
        evalLandProcVar(this,mode,bEnd,node,nNodes);
        saveChkPt(this,core,nCores);
        loadChkPt(this,core,nCores);
       %% functions to organize local cores to avoid dir operation conflicts
        nCoresLS=getNumOfLSCores(this);
        %[coreList,isMin,nCoresLS]=checkThePool(this,core);
        %cleanLocal(this,coreList,core,nCoresLS);
        %checkLocStartPerm(this,core);
        %reportFinish(this,core);
        %dispose(this,coreList);
    end
    methods(Static)
        makeMosaicLocDir(resPathInitLoc,pathSplitor,nCoresLS)
    end
end