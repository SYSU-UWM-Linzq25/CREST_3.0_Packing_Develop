function ImportForcing(this,core,nCores)
%% update history
% 2) added forecast capability
%% import forcing from external to internal without doing any simulation
% mkdir(this.forcingVar.dirLocal);
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
end
