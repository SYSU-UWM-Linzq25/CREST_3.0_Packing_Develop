function CRESTOptimizerMonitor(ctlFile,nCores)
curFile = mfilename('fullpath');
[curDir,~,~]=fileparts(curFile);
[progDir,~,~]=fileparts(curDir);
addpath([progDir,'/optimization_npl']);
globalPar=GlobalParameters(ctlFile);
%% locate the communication folder
switch globalPar.OS
    case 'linux'
        pathSplitor='/';
    case 'windows'
        pathSplitor='\';
end

resPath=globalPar.resPathEx;
comFolder=[resPath,'com',pathSplitor];
statusFolder=[resPath,'status',pathSplitor];
if exist(comFolder,'dir')==7
    rmdir(comFolder,'s');
end
mkdir (comFolder);
if exist(statusFolder,'dir')~=7
    mkdir(statusFolder);
end
%% create a optimizer Monitor
optimizer=SCEUA_Optimizer(globalPar.calibPath,globalPar.resPathEx,globalPar.out_STCD,nCores,comFolder,statusFolder);
%monitor=IOMonitor(maxIO,comFolder,nCores);
%% start to monitor
optimizer.optimizeMultiTask()
optimizer.exportRes(globalPar.paramPath);
clear globalPar
disp('All workers completed. Monitor exists.');
end