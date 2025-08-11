function CRESTIOMonitor_LS(ctlFile,nCores,maxIO,TaskIndex)
Total_startTime = tic;
curFile = mfilename('fullpath');
[curDir,~,~]=fileparts(curFile);
[progDir,~,~]=fileparts(curDir);
addpath([progDir,'/IO']);
globalPar=GlobalParameters(ctlFile);
%% locate the communication folder
switch globalPar.OS
    case 'linux'
        pathSplitor='/';
    case 'windows'
        pathSplitor='\';
end

% CREST Packing - April 19th 2025 - Linzq25
% Ensure coreNo and nCores are numeric
if ischar(maxIO)
    maxIO = str2double(maxIO);
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

% Define task types
taskTypes = {'ImportForc','LandSurf', 'Mosaic','Routing'};
%taskTypes = {'Routing'};
root_com_folder = fileparts(globalPar.forcingCtl);
clear globalPar

% CREST Packing - April 19th 2025 - Linzq25
% Choose which task type to run
if runSingleTask
    taskIndices = TaskIndex; 
else
    taskIndices = 1:length(taskTypes); 
end

for taskIdx = taskIndices
    startTime = tic;
    taskType = taskTypes{taskIdx};
    fprintf('Starting New monitor for "%s"\n', taskType);
    comFolder = [root_com_folder, pathSplitor, 'com_',taskType, pathSplitor];
    if exist(comFolder,'dir')~=7
        mkdir (comFolder);
    end
    if strcmpi(taskType, 'Routing')
        Routing_startfile = [comFolder, 'Routing.start'];
        fid = fopen(Routing_startfile, 'w');
        fclose(fid);
        break
    end
    files = dir(fullfile(comFolder, '*.finished'));
    while length(dir(fullfile(comFolder, '*.finished'))) < nCores
        pause(3);
    end
    %% create a I/O Monitor
    %monitor=IOMonitor(maxIO,comFolder,nCores);
    %% start to monitor
    % monitor.monitorMatlab();
    %monitor.monitor();
    elapsedTime = toc(startTime);
    fprintf('All workers completed. Monitor exists. For "%s": %.6f seconds\n', taskType, elapsedTime);
end
Total_elapsedTime = toc(Total_startTime);
fprintf('ALL CREST LS steps done! Total time: %.6f seconds\n', Total_elapsedTime);
end
