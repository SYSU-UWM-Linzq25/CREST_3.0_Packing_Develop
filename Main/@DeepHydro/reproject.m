function reproject(this,core,nCores)
this.forcingVar.initializeIOCoordinator(core);
[coreList,isMin]=this.forcingVar.ioLocker.checkThePool();
% monCur=[];
dirLoc=[this.globalVar.resPathInitLoc];
dirLocOut=[dirLoc,'out'];
if isMin % the core# is the minimal among all local cores, do the cleaning
    this.forcingVar.ioLocker.cleanLocal(coreList,this.globalVar.resPathInitLoc,...
        @DeepHydro.makeDELocDir,this.globalVar.resPathInitLoc,this.forcingVar.pathSplitor);
    for n=1:length(this.nodes)
        dirLocOutNode=[dirLocOut,this.forcingVar.pathSplitor,this.nodes(n).STCD];
        outletDir=[this.globalVar.resPathDeepLS,this.nodes(n).STCD];
        if exist(dirLocOutNode,'dir')~=7
            mkdir(dirLocOutNode);
        end
        if exist(outletDir,'dir')~=7
            mkdir(outletDir);
        end
    end
else % wait the min core to clean the directory and create the working folder
    this.forcingVar.ioLocker.checkLocStartPerm();
end
moveBack=false;
mode='simu';
this.forcingVar.reset(mode,this.globalVar.taskType,moveBack,core,nCores);
bCont=true;
%% reproject the geographic grids to ED grids for each time step
while bCont
    disp(datestr(this.forcingVar.dateCur,'yyyy/mm/dd:HH:MM'));
    this.LoadDirectRunoff();
    changed=this.forcingVar.hasFileChanged();
    fileFlushed=this.landsurf2DE();
    bCont=this.forcingVar.MoveNext(mode,this.globalVar.taskType);
    %% move a mosaiced file from cache to the target folder
    if this.forcingVar.dateCur~=this.forcingVar.dateStart && (changed || (~bCont)) % move the mosaic file from the local folder to the external one
        this.forcingVar.ioLocker.request();
        this.forcingVar.ioLocker.checkPermission();
        for n=1:length(this.nodes)
            outletDir=[this.globalVar.resPathDeepLS,this.nodes(n).STCD];
            if exist(outletDir,'dir')~=7
                mkdir(outletDir);
            end
            fileExport=[outletDir,this.forcingVar.pathSplitor,fileFlushed];
            fileLocal=[dirLocOut,this.forcingVar.pathSplitor,this.nodes(n).STCD,this.forcingVar.pathSplitor,fileFlushed];
            movefile(fileLocal,fileExport,'f');
        end
        disp(['moved a monthly mosaiced file from ',fileLocal  ' to ', fileExport]);
        this.forcingVar.ioLocker.release();
    end
end
%% clear unused local directories
this.forcingVar.ioLocker.reportLocalFinish();
disp(['core ' num2str(this.forcingVar.ioLocker.coreID) 'exited']);
if isMin
    this.forcingVar.ioLocker.dispose(coreList,this.globalVar.resPathInitLoc);
end
this.forcingVar.ioLocker.finalize();
end