function [fileLocal,fileExport]=FlushToRes(this,dirLocMosaicOut,varListInFile,varListInMem)
%% 1) updated for runs spaning less than a day by Shen. X in Oct. 2019
global fileSto
switch fileSto
    case 'm'
        fmtFile='yyyymm';
    case 'd'
        if strcmpi(this.forcingVar.fmtSubDir,'yyyymmddHH')
            fmtFile = 'yyyymmddHH';
        else
            fmtFile='yyyymmdd';
        end
end
[fileExport,subName]=StateVariables.GenerateOutVarNames(this.globalVar.resPathAgger,...
        this.forcingVar.dateLastCoarse,this.globalVar.timeFormatRoute,...
        fmtFile,this.forcingVar.pathSplitor);

% [fileExport,subName]=StateVariables.GenerateOutVarNames(this.globalVar.resPathAgger,...
%         this.forcingVar.dateLastCoarse,this.globalVar.timeFormatRoute,...
%         this.forcingVar.fmtSubDir,this.forcingVar.pathSplitor);    
    
[~,fileName,ext]=fileparts(fileExport);
fileLocal=[dirLocMosaicOut,this.forcingVar.pathSplitor,fileName,ext];

%% 1) copy the external file to the local folder in case early hours exist
if exist(fileExport,'file')==2 && exist(fileLocal,'file')~=2
    disp('Existing result file detected')
    disp('Copying the old file to append...')
    copyfile(fileExport,fileLocal);
end
%% end 1)
%% save a new timestep of variables
cmdSave=['save ' fileLocal];
for i=1:length(varListInFile)
    % copy values from stateVar variables to datetime named variables
    cmd=[varListInFile{i},'_',subName,'=',varListInMem{i},';'];
    eval(cmd)
    cmdSave=[cmdSave, ' ', varListInFile{i},'_',subName,' '];
end
% save time aggregated & mosaic variables to a file of coarse time line
if exist(fileLocal,'file')~=2
    cmdSave=[cmdSave ' -v7.3'];
else
    cmdSave=[cmdSave ' -append'];
end
eval(cmdSave);
%% set all state variables to zero for the aggregation in the next time step
this.stateVar.rain(this.stateVar.basinMask)=0;
this.stateVar.snow(this.stateVar.basinMask)=0;
this.stateVar.SWE(this.stateVar.basinMask)=0;
this.stateVar.intRain(this.stateVar.basinMask)=0;
this.stateVar.intSnow(this.stateVar.basinMask)=0;
this.stateVar.EAct(this.stateVar.basinMask)=0;
this.stateVar.excS(this.stateVar.basinMask)=0;
this.stateVar.excI(this.stateVar.basinMask)=0;
this.stateVar.rainBare(this.stateVar.basinMask)=0;%/MODIFIED
this.stateVar.actTranspir(this.stateVar.basinMask)=0; %/MODIFIED
this.stateVar.EPot(this.stateVar.basinMask)=0; %/MODIFIED
this.stateVar.W0=0;
this.stateVar.SM(this.stateVar.basinMask)=0;
end
