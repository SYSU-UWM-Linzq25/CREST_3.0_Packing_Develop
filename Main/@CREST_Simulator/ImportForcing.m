function ImportForcing(this,core,nCores)
%% update history
% 2) added forecast capability
%% import forcing from external to internal without doing any simulation
% mkdir(this.forcingVar.dirLocal);
this.forcingVar.initializeIOCoordinator(core);
% [coreList,isMin]=this.forcingVar.ioLocker.checkThePool();
% if isMin % the core# is the minimal among all local cores, do the cleaning
%     this.forcingVar.ioLocker.cleanLocal(coreList,this.globalVar.resPathInitLoc,[]);
% else % wait the min core to clean the directory and create the working folder
%     this.forcingVar.ioLocker.checkLocStartPerm();
% end
%% create folder structure in the local machine
coreDirLoc=[this.forcingVar.dirLocal,num2str(core),'_',num2str(nCores)];
coreDirLocIn=[coreDirLoc,this.forcingVar.pathSplitor,'in'];
coreDirLocOut=[coreDirLoc,this.forcingVar.pathSplitor,'out'];
mkdir(coreDirLoc);
mkdir(coreDirLocIn);
mkdir(coreDirLocOut);
%% run the model
%% begin 2)
% this.forcingVar.reset('simu',this.globalVar.taskType,false,core,nCores);
bEnd=this.forcingVar.reset(this.globalVar.runStyle,this.globalVar.taskType,false,core,nCores);
%% end 2)
if bEnd
    bCont=false;
else
    bCont=true;
end
while bCont
    disp(datestr(this.forcingVar.dateCur,'yyyy/mm/dd:HH:MM'))
    bCont=this.forcingVar.MoveNext('simu',this.globalVar.taskType,core,nCores);
end
%% clean the local folders and report finish of the core
% this.forcingVar.ioLocker.reportLocalFinish();
disp(['core ' num2str(core) 'exited.']);
% if isMin
    % this.forcingVar.ioLocker.dispose(coreList,this.forcingVar.dirLocal);
% end
% this.forcingVar.ioLocker.finalize();
end