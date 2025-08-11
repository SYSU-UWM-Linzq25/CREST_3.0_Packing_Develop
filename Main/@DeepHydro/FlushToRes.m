function fileName=FlushToRes(this,dirLocDE,varNames,varMats)
global fileSto
switch fileSto
    case 'm'
        fmtFile='yyyymm';
    case 'd'
        fmtFile='yyyymmdd';
end
[~,nodeSTCD,~]=fileparts(dirLocDE);
[fileExport,subName]=StateVariables.GenerateOutVarNames([this.globalVar.resPathDeepLS,nodeSTCD,this.forcingVar.pathSplitor],...
        this.forcingVar.dateCur,this.globalVar.timeFormatRoute,...
        fmtFile,this.forcingVar.pathSplitor);
    
[~,fileName,ext]=fileparts(fileExport);
fileLocal=[dirLocDE,this.forcingVar.pathSplitor,fileName,ext];
%% 1) copy the external file to the local folder in case an early hour exist
if exist(fileExport,'file')==2 && exist(fileLocal,'file')~=2
    disp('Existing result file detected')
    this.forcingVar.ioLocker.request();
    this.forcingVar.ioLocker.checkPermission();
    disp('Copying the old file to append...')
    copyfile(fileExport,fileLocal);
    this.forcingVar.ioLocker.release();
end
%% end 1)
%% save a new timestep of variables
cmdSave=['save ' fileLocal];
for i=1:length(varNames)
    % copy values from stateVar variables to datetime named variables
    cmd=[varNames{i},'_',subName,'=','varMats{i}',';'];
    eval(cmd)
    cmdSave=[cmdSave, ' ', varNames{i},'_',subName,' '];
end
% save time aggregated & mosaic variables to a file of coarse time line
if exist(fileLocal,'file')~=2
    cmdSave=[cmdSave ' -v7.3'];
else
    cmdSave=[cmdSave ' -append'];
end
eval(cmdSave);
[~,fileName,ext]=fileparts(fileExport);
fileName=[fileName,ext];
end