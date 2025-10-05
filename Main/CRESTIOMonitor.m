function CRESTIOMonitor(ctlFile,nCores,maxIO)
curFile = mfilename('fullpath');
[curDir,~,~]=fileparts(curFile);
[progDir,~,~]=fileparts(curDir);
addpath([progDir,'/IO']);
globalPar=GlobalParameters(ctlFile);
%% locate the communication folder
switch globalPar.taskType
    case 'ImportForc'% find the common
        comFolder=fileparts(globalPar.forcingCtl);
%         fclose(ffileID);
    case 'LandSurf'
%         ffileID=fopen(globalPar.forcingCtl);
%         pathInt=ForcingVariables.ReadAKeyword(ffileID,'PrecPathInt','#');
        [comFolder,~,~]=fileparts(globalPar.forcingCtl);
%         comFolder=fileparts(comFolder);
%         fclose(ffileID);
%         comFolder=[comFolder,pathSplitor];
    case 'Mosaic'
%         ffileID=fopen(globalPar.forcingCtl);
%         pathInt=ForcingVariables.ReadAKeyword(ffileID,'PrecPathInt','#');
%         [comFolder,~,~]=fileparts(pathInt);
        comFolder=fileparts(globalPar.forcingCtl);
%         fclose(ffileID);
    case 'DeepHydro_regrid'
        comFolder=fileparts(globalPar.forcingCtl);
end
comFolder=fullfile(comFolder,'com');
if exist(comFolder,'dir')~=7
    mkdir (comFolder);
end
clear globalPar
%% create a I/O Monitor
monitor=IOMonitor(maxIO,comFolder,nCores);
%% start to monitor
% monitor.monitorMatlab();
monitor.monitor();
disp('All workers completed. Monitor exists.');
end