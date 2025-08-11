function CRESTOptimizer(globalCtlFile,slopeMode,coreNo,nCores)
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('%         CREST v3.0, released Jan. 2016         %')
disp('% COUPLED ROUTING AND EXCESS STORAGE (UCONN)     %')
disp('%      contact: xinyi.shen@uconn.edu             %')
disp('%               manos@engr.uconn.edu             %')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('configuring environment...')
curFile = mfilename('fullpath');
[curDir,~,~]=fileparts(curFile);
[progDir,~,~]=fileparts(curDir);

addpath([progDir,'/MEX']);
addpath([progDir,'/IO']);
addpath([progDir,'/Numeric']);
addpath([progDir,'/Numeric/lindfield-penny2/na_funcs']);
addpath([curDir,'/common']);
addpath([curDir,'/energy_balances']);
addpath([progDir,'/optimiz_zyc']);
sysBit=mexext;
if strcmpi(sysBit,'mexw64')~=1
    dllDir=[progDir,'\DLL'];
    setenv('PATH', [getenv('PATH') ';' dllDir]);
    warning('not a windows x64 system.\n Users need to compile the GDAL library themselves.')
end
disp('loading GDAL v1.11.0...')
GDALLoad();
define_constant();
model_settings();
globalPar=GlobalParameters(globalCtlFile);
% if globalPar.numOfLoaded>0
%     startDate=globalPar.warmupDate;
% else
%     startDate=globalPar.startDate;
% end
%% initialize basic variable object
if ~exist('coreNo','var') && ~exist('nCores','var')
    coreNo=0;
    nCores=0;
end
if strcmpi(globalPar.taskType,'Mosaic')
    % find nCoresLS
    coreDirs=dir([globalPar.resPathInit,'*_*']);
    strs=strsplit(coreDirs(1).name,'_');
    nCoresLS=str2double(strs{2});
    basinVar=BasinVariables(globalPar.basicPath,globalPar.basicFormat,globalPar.timeMarkRoute,...
        globalPar.autoClip,globalPar.out_shp,globalPar.out_STCD,globalPar.DEMExt,globalPar.FDRExt,globalPar.FACExt,globalPar.streamExt,...
        globalPar.taskType,coreNo,nCoresLS,globalPar.resPathNodeMasks);
else
    basinVar=BasinVariables(globalPar.basicPath,globalPar.basicFormat,globalPar.timeMarkRoute,...
        globalPar.autoClip,globalPar.out_shp,globalPar.out_STCD,globalPar.DEMExt,globalPar.FDRExt,globalPar.FACExt,globalPar.streamExt,...
        globalPar.taskType,coreNo,nCores,globalPar.resPathNodeMasks);
end
%% create the hydroSites
if ~strcmpi(globalPar.taskType,'Routing');
    hydroSites=HydroSites(globalPar.out_shp,basinVar.geoTrans,basinVar.spatialRef,...
                globalPar.obsNoData,globalPar.nTimeStepsLS,globalPar.startDateLS,globalPar.endDateLS,1,...
                globalPar.timeStepLS,globalPar.warmupDateLS,...
                globalPar.calibPath,basinVar.nodeIndRef);
else
    hydroSites=HydroSites(globalPar.out_shp,basinVar.geoTrans,basinVar.spatialRef,...
                globalPar.obsNoData,globalPar.nTimeStepsRoute,globalPar.startDateRoute,globalPar.endDateRoute,max(1,length(globalPar.startDateRoute)),...
                globalPar.timeStepRoute,globalPar.warmupDateRoute,...
                globalPar.calibPath,basinVar.nodeIndRef);
    hydroSites.ImportObservation(globalPar.eventMode,globalPar.obsPath,globalPar.FEDB,globalPar.obsFormat,globalPar.out_STCD);
end
if strcmpi(globalPar.taskType,'Routing')
    basinVar.CalSlope(slopeMode,hydroSites.row(hydroSites.indexOutlets),hydroSites.col(hydroSites.indexOutlets));
    basinVar.GetSubMasks(hydroSites.row,hydroSites.col,hydroSites.STCD,globalPar.resPathNodeMasks);
end
%% initialize model parameters
modelPar=ModelParameters(globalPar.paramPath,basinVar.basinMask,basinVar.geoTrans,basinVar.spatialRef);
%% create the state-variable object
if ~strcmpi(globalPar.taskType,'Routing');
    stateVar=StateVariables(hydroSites,...
                        globalPar.timeMarkLS,globalPar.timeStepInMLS,... 
                        basinVar.basinMask,basinVar.stream,...
                        globalPar.ICSPath,basinVar.geoTrans,basinVar.spatialRef,modelPar.nLayers);
else
    stateVar=StateVariables(hydroSites,...
                        globalPar.timeMarkRoute,globalPar.timeStepInMRoute,... 
                        basinVar.basinMask,basinVar.stream,...
                        globalPar.ICSPath,basinVar.geoTrans,basinVar.spatialRef,modelPar.nLayers);
end
%% create the forcing-variable object
switch globalPar.taskType
    case 'ImportForc'
        forcingVar=ForcingVariables(basinVar.basinMask,basinVar.maskEnt,basinVar.geoTrans,basinVar.spatialRef,...
            globalPar.startDateLS,globalPar.endDateLS,globalPar.timeStepLS,globalPar.timeFormatLS,globalPar.timeMarkLS,...
            [],[],[],...
            globalPar.forcingCtl,...    
            globalPar.decompBeforeSrc,globalPar.decompBeforeDst,globalPar.OS);
    case 'LandSurf'
        forcingVar=ForcingVariables(basinVar.basinMask,basinVar.maskEnt,basinVar.geoTrans,basinVar.spatialRef,...
            globalPar.startDateLS,globalPar.endDateLS,globalPar.timeStepLS,globalPar.timeFormatLS,globalPar.timeMarkLS,...
            [],[],[],...
            globalPar.forcingCtl,...    
            globalPar.decompBeforeSrc,globalPar.decompBeforeDst,globalPar.OS);
    case 'Mosaic'
        forcingVar=ForcingVariables(basinVar.basinMask,basinVar.maskEnt,basinVar.geoTrans,basinVar.spatialRef,...
            globalPar.startDateLS,globalPar.endDateLS,globalPar.timeStepLS,globalPar.timeFormatLS,globalPar.timeMarkLS,...
            globalPar.startDateRoute,globalPar.endDateRoute,globalPar.timeStepRoute,...
            globalPar.forcingCtl,...    
            globalPar.decompBeforeSrc,globalPar.decompBeforeDst,globalPar.OS);
    case 'Routing'
        forcingVar=ForcingVariables(basinVar.basinMask,basinVar.maskEnt,basinVar.geoTrans,basinVar.spatialRef,...
            globalPar.startDateRoute,globalPar.endDateRoute,globalPar.timeStepRoute,globalPar.timeFormatRoute,globalPar.timeMarkRoute,...
            [],[],[],...
            globalPar.forcingCtl,...    
            globalPar.decompBeforeSrc,globalPar.decompBeforeDst,globalPar.OS);
end
basinVar.maskEnt=[];

%% create the simulator object!!!
simulator=CREST_Simulator(modelPar,basinVar,stateVar,forcingVar,globalPar);

%% perform simulation or calibration
tic
switch globalPar.runStyle
    case 'simu'
        switch globalPar.taskType
            case 'Routing'
                NSCE=simulator.Simulate_Routing();
                stateVar.SaveStates(globalPar.resPathEx);
            case 'LandSurf'
                simulator.Simulate_LandSurf(coreNo,nCores);
            case 'ImportForc'
                simulator.ImportForcing(coreNo,nCores)
            case 'Mosaic'
                simulator.mosaic(coreNo,nCores);
        end
    case 'cali_SCEUA'
        warning('off','all');
        resPath=globalPar.resPathEx;
        comFolder=[resPath,'com',forcingVar.pathSplitor];
        statusFolder=[resPath,'status',forcingVar.pathSplitor];
        if exist(comFolder,'dir')~=7
            mkdir (comFolder);
        end
        if exist(statusFolder,'dir')~=7
            mkdir(statusFolder);
        end
        %create the worker object
        crestWorker=SCEUA_Worker(coreNo,globalPar.resPathEx,globalPar.out_STCD,comFolder,statusFolder);
        
        % the function handle is actually BasicVar.Simulate
        funcHandle=@Simulate_Routing;
        if strcmpi(globalPar.calibMode,'parallel')
            %optimizer.optimize('par');
            bEnd=false;
            while ~bEnd
                bEnd=crestWorker.work(simulator,funcHandle);
            end
            bEvolveEnd=false;
            while ~bEvolveEnd
                bEvolveEnd=crestWorker.workEvolve(simulator,funcHandle);
            end

        else
            optimizer.optimize('seq');% the server does not have a MDCS license now
        end
end
toc
disp('done!');
end
