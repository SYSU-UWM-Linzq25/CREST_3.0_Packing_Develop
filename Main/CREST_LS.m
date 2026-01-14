function CREST_LS(globalCtlFile,slopeMode,coreNo,nCores,TaskIndex)
%% update history
% 1) update for operational stability
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

addpath([progDir,'/MEX_2.3.0']);
addpath([progDir,'/Support/IO']);
addpath([progDir,'/Support/Numeric']);
addpath([progDir,'/Support/Numeric/lindfield-penny2/na_funcs']);
addpath([curDir,'/common']);
addpath([curDir,'/energy_balances']);
addpath([progDir,'/Support/optimization_npl']);
addpath([progDir,'/Support/ThirdPartyM/xticklabel_rotate']);
%sysBit=mexext;
%if strcmpi(sysBit,'mexw64')==1
%    dllDir=[progDir,'\DLL'];
%    setenv('PATH', [getenv('PATH') ';' dllDir]);
%end
disp('loading GDAL')
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

% CREST Packing - April 19th 2025 - Linzq25
% Ensure coreNo and nCores are numeric
if ischar(coreNo)
    coreNo = str2double(coreNo);
end
if ischar(nCores)
    nCores = str2double(nCores);
end

% Choose which task type to run
if ~exist('TaskIndex','var') || isempty(TaskIndex)
    runSingleTask = false;
else
    runSingleTask = true;
    if ischar(TaskIndex)
        TaskIndex = str2double(TaskIndex);
    elseif ~isnumeric(TaskIndex)
        error('TaskIndex must be numeric or a numeric string');
    end
end

switch globalPar.OS
    case 'linux'
        pathSplitor='/';
    case 'windows'
        pathSplitor='\';
end

% Define task types
taskTypes = {'ImportForc','LandSurf','Mosaic'};
%taskTypes = {'Routing'};
root_com_folder = fileparts(globalPar.forcingCtl);

% CREST Packing - April 19th 2025 - Linzq25
% Choose which task type to run
if runSingleTask
    taskIndices = TaskIndex; 
else
    taskIndices = 1:length(taskTypes); 
end

for taskIdx = taskIndices
    task_start = tic;
    globalPar.taskType = taskTypes{taskIdx};
    comFolder = [root_com_folder, pathSplitor, 'com_',globalPar.taskType, pathSplitor];
    while exist(comFolder,'dir')~=7
        pause(5);
    end
    % Check if basinVar exists
    if exist('basinVar', 'var')
        clear basinVar;
    end

    % Check if hydroSites exists
    if exist('hydroSites', 'var')
        clear hydroSites;
    end

    % Check if modelPar exists
    if exist('modelPar', 'var')
        clear modelPar;
    end

    % Check if forcingVar exists
    if exist('forcingVar', 'var')
        clear forcingVar;
    end

    % Check if simulator exists
    if exist('simulator', 'var')
        clear simulator;
    end
    if strcmpi(globalPar.taskType,'Mosaic')
        CREST_Simulator.makeMosaicLocDir(globalPar.resPathInitLoc,pathSplitor,nCores)
    end
    %% 1)
    %% clean the local folder
    if false
        ioLocker = initialize_IO(comFolder, coreNo);
        [coreList,isMin]=ioLocker.checkThePool();
        if isMin % the core# is the minimal among all local cores, do the cleaning
            if strcmpi(globalPar.taskType,'Mosaic')
                ioLocker.cleanLocal(coreList,globalPar.resPathInitLoc,...
                    @CREST_Simulator.makeMosaicLocDir,globalPar.resPathInitLoc,pathSplitor,nCores);
            else
                ioLocker.cleanLocal(coreList,globalPar.resPathInitLoc,[]);
            end
        else % wait the min core to clean the directory and create the working folder
            ioLocker.checkLocStartPerm();
        end
    end

    try
        if strcmpi(globalPar.taskType,'Mosaic')
            % find nCoresLS
            if strcmpi(globalPar.runStyle,'forecast')
                indDTS=strfind(globalPar.resPathInit,'DTS');
                resInit=globalPar.resPathInit;
                resInit=[resInit(1:indDTS-1),'*',resInit(indDTS+3:end)];
                coreDirs=dir([resInit,'*_*']);
            else
                coreDirs=dir([globalPar.resPathInit,'*_*']);
            end
            if isempty(coreDirs)% the data is mosaiced but not aggregated
                nCoresLS=1;
            else
                strs=strsplit(coreDirs(1).name,'_');
                nCoresLS=str2double(strs{2});
            end
            basinVar=BasinVariables(globalPar.basicPath,globalPar.basicFormat,globalPar.timeMarkRoute,...
                globalPar.autoClip,globalPar.out_shp,globalPar.out_STCD,globalPar.DEMExt,globalPar.FDRExt,globalPar.FACExt,globalPar.streamExt,...
                globalPar.taskType,coreNo,nCoresLS,globalPar.resPathNodeMasks);
        else
            basinVar=BasinVariables(globalPar.basicPath,globalPar.basicFormat,globalPar.timeMarkRoute,...
                globalPar.autoClip,globalPar.out_shp,globalPar.out_STCD,globalPar.DEMExt,globalPar.FDRExt,globalPar.FACExt,globalPar.streamExt,...
                globalPar.taskType,coreNo,nCores,globalPar.resPathNodeMasks);
        end
        %% create the hydroSites
        if ~strcmpi(globalPar.taskType,'Routing')
            hydroSites=HydroSites(globalPar.out_shp,basinVar.geoTrans,basinVar.spatialRef,...
                globalPar.obsNoData,globalPar.nTimeStepsLS,globalPar.startDateLS,globalPar.endDateLS,1,...
                globalPar.timeStepLS,globalPar.warmupDateLS,...
                globalPar.calibPath,basinVar.nodeIndRef,coreNo,nCores);
        else
            hydroSites=HydroSites(globalPar.out_shp,basinVar.geoTrans,basinVar.spatialRef,...
                globalPar.obsNoData,globalPar.nTimeStepsRoute,globalPar.startDateRoute,globalPar.endDateRoute,max(1,length(globalPar.startDateRoute)),...
                globalPar.timeStepRoute,globalPar.warmupDateRoute,...
                globalPar.calibPath,basinVar.nodeIndRef,coreNo,nCores);
            hydroSites.ImportObservation2(globalPar.eventMode,globalPar.obsPath,globalPar.FEDB,globalPar.obsFormat,globalPar.out_STCD);
        end
        if strcmpi(globalPar.taskType,'Routing')
            basinVar.CalSlope(slopeMode,hydroSites.row(hydroSites.indexOutlets),hydroSites.col(hydroSites.indexOutlets));
            [param_path,~,~]=fileparts(globalPar.paramPath);
            basinVar.GetSubMasks(hydroSites.row,hydroSites.col,hydroSites.STCD,param_path);
            % Initialize the total valid mask with false (logical 0)
            totalValidMask = false(size(basinVar.masks(:,:,1)));
            % Iterate through each mask
            for i = 1:hydroSites.nSites
                % Perform logical OR operation with the cumulative mask
                totalValidMask = totalValidMask | basinVar.masks(:,:,i);
            end
            % Convert the total valid mask to logical
            totalValidMask = logical(totalValidMask);
            basinVar.basinMask = basinVar.basinMask & totalValidMask;
        end
        %% initialize model parameters
        modelPar=ModelParameters(globalPar.paramPath,basinVar.basinMask,basinVar.geoTrans,basinVar.spatialRef);
        %% create the state-variable object
        if ~strcmpi(globalPar.taskType,'Routing')
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
        isFore=strcmpi(globalPar.runStyle,'forecast');
        switch globalPar.taskType
            case 'ImportForc'
                forcingVar=ForcingVariables(basinVar.basinMask,basinVar.maskEnt,basinVar.geoTrans,basinVar.spatialRef,...
                    globalPar.startDateLS,globalPar.endDateLS,globalPar.timeStepLS,globalPar.timeFormatLS,globalPar.timeMarkLS,...
                    [],[],[],...
                    globalPar.forcingCtl,globalPar.taskType,...
                    globalPar.decompBeforeSrc,globalPar.decompBeforeDst,globalPar.OS,isFore,false);
            case 'LandSurf'
                forcingVar=ForcingVariables(basinVar.basinMask,basinVar.maskEnt,basinVar.geoTrans,basinVar.spatialRef,...
                    globalPar.startDateLS,globalPar.endDateLS,globalPar.timeStepLS,globalPar.timeFormatLS,globalPar.timeMarkLS,...
                    [],[],[],...
                    globalPar.forcingCtl,globalPar.taskType,...
                    globalPar.decompBeforeSrc,globalPar.decompBeforeDst,globalPar.OS,isFore,false);
            case 'Mosaic'
                forcingVar=ForcingVariables(basinVar.basinMask,basinVar.maskEnt,basinVar.geoTrans,basinVar.spatialRef,...
                    globalPar.startDateLS,globalPar.endDateLS,globalPar.timeStepLS,globalPar.timeFormatLS,globalPar.timeMarkLS,...
                    globalPar.startDateRoute,globalPar.endDateRoute,globalPar.timeStepRoute,...
                    globalPar.forcingCtl,globalPar.taskType,...
                    globalPar.decompBeforeSrc,globalPar.decompBeforeDst,globalPar.OS,isFore,false);
            case 'Routing'
                forcingVar=ForcingVariables(basinVar.basinMask,basinVar.maskEnt,basinVar.geoTrans,basinVar.spatialRef,...
                    globalPar.startDateRoute,globalPar.endDateRoute,globalPar.timeStepRoute,globalPar.timeFormatRoute,globalPar.timeMarkRoute,...
                    [],[],[],...
                    globalPar.forcingCtl,globalPar.taskType,...
                    globalPar.decompBeforeSrc,globalPar.decompBeforeDst,globalPar.OS,isFore,true);
        end
        basinVar.maskEnt=[];
        %% create the simulator object
        simulator=CREST_Simulator(modelPar,basinVar,stateVar,forcingVar,globalPar);
        %% perform simulation or calibration
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
            case 'analysis'
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
            case 'forecast'
                switch globalPar.taskType
                    case 'Routing'
                        NSCE=simulator.Simulate_Routing();
                        stateVar.SaveStates(globalPar.resPathEx);
                        stateVar.genHydrograph(globalPar.resPathEx,forcingVar.dateStart);
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
                    warning('off','all');
                    % the function handle is actually BasicVar.Simulate
                    funcHandle=@Simulate_Routing;
                    optimizer=SCEUA_Optimizer(globalPar.calibPath,globalPar.resPathEx,globalPar.out_STCD,...
                        funcHandle,simulator,nCores);
                    optimizer.optimize('seq');% the server does not have a MDCS license now
                    optimizer.exportRes(globalPar.resPathEx,globalPar.out_STCD);
                end
                %
                %         if strcmpi(globalPar.calibMode,'parallel')
                %             optimizer.optimize('par');
                %         else
                %             optimizer.optimize('seq');% the server does not have a MDCS license now
                %         end
                %% clean the local folders and report finish of the cor
        end
        if false
            ioLocker.reportLocalFinish();
            disp(['core ' num2str(ioLocker.coreID) ' exited']);
            if isMin
                ioLocker.dispose(coreList,this.globalVar.resPathInitLoc);
            end
            ioLocker.finalize();
            disp('done!');
        end
        finished_file = [comFolder, 'core_', num2str(coreNo), '.finished'];
        fid = fopen(finished_file, 'w');
        fclose(fid);
        task_end = toc(task_start);
        disp(['Core', num2str(coreNo) ,' done task ',globalPar.taskType,' finished using ',num2str(task_end),' seconds']);
    catch ME
        errorMessage = sprintf('Error in function %s() at line %d.\n\nError Message:\n%s', ...
            ME.stack(1).name, ME.stack(1).line, ME.message);
        fprintf(1, '%s\n', errorMessage);
        try
            forcingVar.ioLocker.finalize('Aborted');
        catch
            disp([num2str(coreNo),'Aborted']);
        end
    end
end
end

