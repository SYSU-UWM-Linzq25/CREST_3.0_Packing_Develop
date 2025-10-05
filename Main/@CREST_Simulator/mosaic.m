function mosaic(this,core,nCores)
mode='simu';% mosaic will never be called in calibration style
%% clear the local folder and initialize the IOLocker
this.forcingVar.initializeIOCoordinator(core);
% [coreList,isMin]=this.forcingVar.ioLocker.checkThePool();
nCoresLS=this.getNumOfLSCores();
this.oldResFile=cell(nCoresLS,1);
% monCur=[];
% if isMin % the core# is the minimal among all local cores, do the cleaning
%     this.forcingVar.ioLocker.cleanLocal(coreList,this.globalVar.resPathInitLoc,...
%         @CREST_Simulator.makeMosaicLocDir,this.globalVar.resPathInitLoc,this.forcingVar.pathSplitor,nCoresLS);
% else % wait the min core to clean the directory and create the working folder
%     this.forcingVar.ioLocker.checkLocStartPerm();
% end

this.forcingVar.isMosaic=true;
bCont=~this.forcingVar.reset(mode,this.globalVar.taskType,false,core,nCores);
% isNewDate=false;
[varListInFile,varListInMem]=this.genVarList();% generate the variable list in both memory and file

dirLocMosaic=fullfile(this.globalVar.resPathInitLoc,'mosaic');
dirLocMosaicOut=fullfile(dirLocMosaic,'out');
dirLocMosaicIn=fullfile(dirLocMosaic,'in');
if exist(dirLocMosaic,'dir')~=7
    mkdir(dirLocMosaic);
end
if exist(dirLocMosaicIn,'dir')~=7
    mkdir(dirLocMosaicIn);
end
if exist(dirLocMosaicOut,'dir')~=7
    mkdir(dirLocMosaicOut);
end 
while bCont
    disp(datestr(this.forcingVar.dateCur,'yyyy/mm/dd:HH:MM'))
    this.ImportLandSurfRes(nCoresLS,varListInFile);
    changed=this.forcingVar.hasFileChanged();
    [bCont,isNewDate]=this.forcingVar.MoveNext(mode,this.globalVar.taskType);
    %% flush and mosaic & (aggregate or average variables)
    if isNewDate || (~bCont)% an old date is processed, flush variables to the file in the cache
        [fileLocal,fileExport]=this.FlushToRes(dirLocMosaicOut,varListInFile,varListInMem);
    end
   %% move a mosaiced file from cache to the target folder
    if this.forcingVar.dateCur~=this.forcingVar.dateStart && (changed || (~bCont)) % move the mosaic file from the local folder to the external one
        % this.forcingVar.ioLocker.request();
        % this.forcingVar.ioLocker.checkPermission();
        movefile(fileLocal,fileExport,'f');
        disp(['moved a monthly mosaiced file from ',fileLocal  ' to ', fileExport]);
        % this.forcingVar.ioLocker.release();
    end
%     monCur=monNext;
end
for i=1:nCoresLS
    if ~isempty(this.oldResFile{i})
        delete(this.oldResFile{i});
    end
end
%% clear unused directories
% this.forcingVar.ioLocker.reportLocalFinish();
disp(['core ' num2str(core) 'exited']);
% if isMin
%     this.forcingVar.ioLocker.dispose(coreList,this.globalVar.resPathInitLoc);
% end
% this.forcingVar.ioLocker.finalize();
end