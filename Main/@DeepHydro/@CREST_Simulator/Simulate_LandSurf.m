function Simulate_LandSurf(this,coreNo,nCores,x0,keywords)
%% 2) updated in Sept. 2019 by Shen, X. for the forecast module
%% 1) updated on Feb 27, 2017 by Shen, X.
% reassign all local directory and progress tasks to IOLocker and IOMonitor
%% create output directory in the external folder
mkdir(this.globalVar.resPathChkPts);
%% 2)
% mkdir(this.globalVar.resPathChkPts);
%% end 2)


% core splitted subdirectory to store state variables
stateDir=[this.globalVar.statePath,num2str(coreNo),'_',num2str(nCores)];
mkdir(stateDir);

% core splittted subdirectory to store result
this.coreDir=[this.globalVar.resPathInit,num2str(coreNo),'_',num2str(nCores)];
coreDirLoc=[this.globalVar.resPathInitLoc,num2str(coreNo),'_',num2str(nCores)];
mkdir(this.coreDir);
chkDir=[this.globalVar.resPathChkPts,num2str(coreNo),'_',num2str(nCores)];
mkdir(chkDir);

%% clean the local folder
this.forcingVar.initializeIOCoordinator(coreNo);
% [coreList,isMin]=this.forcingVar.ioLocker.checkThePool();
% if isMin % the core# is the minimal among all local cores, do the cleaning
%     this.forcingVar.ioLocker.cleanLocal(coreList,this.globalVar.resPathInitLoc,[]);
% else % wait the min core to clean the directory and create the working folder
%     this.forcingVar.ioLocker.checkLocStartPerm();
% end
disp(['creating ' coreDirLoc]);
mkdir(coreDirLoc);
% delete([coreDirLoc,this.forcingVar.pathSplitor,'*.mat']);
% delete([this.coreDir,this.forcingVar.pathSplitor,'*.mat']);
% core splittted subdirectory to store check points

if exist('x0','var') && exist('keywards','var')
    mode='calib';
else
    mode='simu';
end
if strcmpi(mode,'calib')
%                 bCalib=true;
    this.ModelParInit(coreNo,nCores,x0,keywords);
else
    this.ModelParInit(coreNo,nCores);
end
this.stateVar.preset(this.basicVar.lake);
this.forcingVar.reset(mode,this.globalVar.taskType,false,coreNo,nCores);
this.presetMedium();
this.stateVar.reset(this.soilSurf.nLayers,this.globalVar.taskType);    
%             t2=cputime;% uncomment for speed test
%             tForce=t2-t1;% uncomment for speed test
%% create the result/local folders and clear existing files
% if exist(coreDirLoc,'dir')==7
%     rmdir(coreDirLoc,'s');
% end
%             dt=0;
bEnd=false;
timeOfStep=1;
t1=cputime;
[~,~,~,hourEnd,minEnd,secEnd]=datevec(this.forcingVar.dateEnd);
this.loadChkPt(coreNo,nCores);

while(~bEnd)
    if ~strcmpi(mode,'calib')
        disp(datestr(this.forcingVar.dateCur,'yyyy/mm/dd:HH:MM'))
    end
    % Convert unite of Rain and PET from mm/dt to mm
    this.GetForcing();
    this.LandSurfProc(coreNo,nCores);
%     disp(['Tair: ',num2str(mean(this.Tair)), ' snow fall: ',...
%         num2str(mean(this.snow(this.parMask))),...
%         ' TSoilSurf: ', num2str(mean(this.soilSurf.TSurf(this.parMask)))]);
%     disp(['max SWE: ', num2str(max(this.snowpack.swqTotal(this.parMask)))])
    this.OutputVar(false,coreNo,nCores);
%     disp(['water balance error: ', num2str(massErr),'(mm/h)']);
    %% save model state variables
%     if ~strcmpi(mode,'calib')
%         if ismember(this.forcingVar.dateCur,this.globalVar.saveDates)
%             dateToSave=datestr(this.forcingVar.dateCur+this.globalVar.saveOffset,this.globalVar.saveDateFormat);
%             this.stateVar.SaveModelStates([this.globalVar.statePath,dateToSave,'.mat'],...
%                 this.modelPar.WM);
%         end
%     end
    %% Save the checkpoint
    [~,~,dayCur,hourCur,minCur,secCur]=datevec(this.forcingVar.dateCur);
    switch (this.globalVar.runStyle)
        case 'simu'
            if dayCur==15 && hourCur==hourEnd &&minCur==minEnd && secCur==secEnd
                this.saveChkPt(coreNo,nCores);
            end
        case 'analysis'
            if hourCur==11 &&minCur==minEnd && secCur==secEnd   %marika
                this.saveChkPt(coreNo,nCores);
            elseif hourCur==23 &&minCur==minEnd && secCur==secEnd   %marika
                this.saveChkPt(coreNo,nCores);
            end
        otherwise
    end
    %% move to the next time step
    timeOfStep=timeOfStep+1;
    bEnd=~this.forcingVar.MoveNext(mode,this.globalVar.taskType,coreNo,nCores);
    %% cell2cell evaulate land surface part
    this.evalLandProcVar(mode,bEnd,coreNo,nCores);
end
% this.forcingVar.ioLocker.cleanLocal(coreNo,nCores);
% copy the last result file to the common folder
if (~isempty(this.oldResFile)) && exist('coreNo','var') && exist('nCores','var')
    % this.forcingVar.ioLocker.request();
    % this.forcingVar.ioLocker.checkPermission();
    movefile(this.oldResFile,[this.coreDir,this.forcingVar.pathSplitor],'f');
    disp('move the last monthly result file to the external folder');
    % this.forcingVar.ioLocker.release();
end
t2=cputime;
tElapse=t2-t1;
disp(['total simulation time: ' num2str(tElapse) 'seconds']);
disp (['total not converged cells by times; ' num2str(this.numOfNotConv)]);
disp (['total cells by times where/where T exceeds limits; ' num2str(this.numOfImpossibleT)]);
if ~strcmpi(mode,'calib') && this.stateVar.hydroSites.nGObs>0
    disp (['NSCE=' num2str(mean(this.stateVar.hydroSites.NSCE{1}))]);
    disp (['Bias=' num2str(mean(abs(this.stateVar.hydroSites.Bias{1})))]);
else %calibration mode
    disp ('NSCE=N/A');
    disp ('Bias=N/A');
end

%% clean the local folders and report finish of the core
% this.forcingVar.ioLocker.reportLocalFinish();
disp(['core ' num2str(coreNo) 'exited']);
% if isMin
%     this.forcingVar.ioLocker.dispose(coreList,this.globalVar.resPathInitLoc);
% end
% this.forcingVar.ioLocker.finalize();

end