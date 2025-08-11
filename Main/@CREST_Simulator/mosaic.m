function mosaic(this,core,nCores)
mode='simu';% mosaic will never be called in calibration style
%% clear the local folder and initialize the IOLocker
this.forcingVar.initializeIOCoordinator(core);
nCoresLS=this.getNumOfLSCores();
this.oldResFile=cell(nCoresLS,1);

this.forcingVar.isMosaic=true;
bCont=~this.forcingVar.reset(mode,this.globalVar.taskType,false,core,nCores);
% isNewDate=false;
[varListInFile,varListInMem]=this.genVarList();% generate the variable list in both memory and file

dirLocMosaic=[this.globalVar.resPathInitLoc,'mosaic'];
dirLocMosaicOut=[dirLocMosaic,this.forcingVar.pathSplitor,'out'];
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
        movefile(fileLocal,fileExport,'f');
        disp(['moved a monthly mosaiced file from ',fileLocal  ' to ', fileExport]);
    end
%     monCur=monNext;
end
for i=1:nCoresLS
    if ~isempty(this.oldResFile{i})
        delete(this.oldResFile{i});
    end
end
end
