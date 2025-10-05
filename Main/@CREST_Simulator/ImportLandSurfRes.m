function ImportLandSurfRes(this,nCoresLS,varListInFile)
%% modification history
% updated by Shen, Xinyi in April, 2016
% local folders are used for inital reading and writing and monthly file
%% save the aggregated result on the last date and reset state varialbes
% reset the imported variables to zero if it is a new date(coarse)
dirLocMosaic=[this.globalVar.resPathInitLoc,'mosaic'];
dirLocMosaicIn=[dirLocMosaic,this.forcingVar.pathSplitor,'in'];
% dirLocMosaicOut=[dirLocMosaic,this.forcingVar.pathSplitor,'out'];
% if isNewDate && this.forcingVar.dateCur>=this.forcingVar.dateStart % do not write any thing to a date that is out of range
%     this.FlushToRes(dirLocMosaicOut,varListInFile,varListInMem);
%     [fileExport,subName]=StateVariables.GenerateOutVarNames(this.globalVar.resPathAgger,...
%         this.forcingVar.dateLastCoarse,this.globalVar.timeFormatRoute,...
%         this.forcingVar.fmtSubDir,this.forcingVar.pathSplitor);
%     [~,fileName,ext]=fileparts(fileExport);
%     fileLocal=[dirLocMosaicOut,this.forcingVar.pathSplitor,fileName,ext];
%     %% save a new timestep of variables
%     cmdSave=['save ' fileLocal];
%     for i=1:length(varListInFile)
%         % copy values from stateVar variables to datetime named variables
%         cmd=[varListInFile{i},'_',subName,'=',varListInMem{i},';'];
%         eval(cmd)
%         cmdSave=[cmdSave, ' ', varListInFile{i},'_',subName,' '];
%     end
%     % save time aggregated & mosaic variables to a file of coarse time line
%     if exist(fileLocal,'file')~=2
%         cmdSave=[cmdSave ' -v7.3'];
%     else
%         cmdSave=[cmdSave ' -append'];
%     end
%     eval(cmdSave);
%     %% set all state variables to zero for the aggregation in the next time step
%     this.stateVar.rain(this.stateVar.basinMask)=0;
%     this.stateVar.snow(this.stateVar.basinMask)=0;
%     this.stateVar.SWE(this.stateVar.basinMask)=0;
%     this.stateVar.intRain(this.stateVar.basinMask)=0;
%     this.stateVar.intSnow(this.stateVar.basinMask)=0;
%     this.stateVar.EAct(this.stateVar.basinMask)=0;
%     this.stateVar.excS(this.stateVar.basinMask)=0;
%     this.stateVar.excI(this.stateVar.basinMask)=0;
%     this.stateVar.W0=0;
% end
%% mosaic results from different cores
% save mosaic result
% [fileOutVarFinal,subName]=StateVariables.GenerateOutVarNames(this.globalVar.resPathMosaic,...
%     this.forcingVar.dateCur,this.globalVar.timeFormatLS,...
%     this.forcingVar.fmtSubDir,this.forcingVar.pathSplitor);
% cmd=['save ' fileOutVarFinal];
if this.globalVar.output_intRain
    intWater=nan(size(this.stateVar.basinMask));
    maskVar='intRain';
%     cmd=[cmd ' intWater'];
end
if this.globalVar.output_intSnow
    intSnow=nan(size(this.stateVar.basinMask));
    maskVar='intSnow';
%     cmd=[cmd ' intSnow'];
end
if this.globalVar.output_W
    W=nan([size(this.stateVar.basinMask),this.modelPar.nLayers]);
    maskVar='W';
%     cmd=[cmd ' W'];
end
if this.globalVar.output_Rain
    rain=nan(size(this.stateVar.basinMask));
    maskVar='rain';
%     cmd=[cmd ' rain'];
end
if this.globalVar.output_Snow
    snow=nan(size(this.stateVar.basinMask));
    maskVar='snow';
%     cmd=[cmd ' snow'];
end
if this.globalVar.output_EAct
    EAct=nan(size(this.stateVar.basinMask));
    maskVar='EAct';
%     cmd=[cmd ' EAct'];
end
if this.globalVar.output_SWE
    SWE=nan(size(this.stateVar.basinMask));
    maskVar='SWE';
%     cmd=[cmd ' SWE'];
end
if this.globalVar.output_ExcS
    excS=nan(size(this.stateVar.basinMask));
    maskVar='excS';
%     cmd=[cmd ' excS'];
end
if this.globalVar.output_ExcI
    excI=nan(size(this.stateVar.basinMask));
    maskVar='excI';
%     cmd=[cmd ' excI'];
end
if this.globalVar.output_rainBare
    rainBare=nan(size(this.stateVar.basinMask));
    maskVar='rainBare';
%     cmd=[cmd ' rainBare'];
end
%/ MOADIFIED
if this.globalVar.output_actTranspir
     actTranspir=nan([size(this.stateVar.basinMask),3]);
    maskVar='actTranspir';
%     cmd=[cmd ' actTranspir'];
end
%/ MOADIFIED
if this.globalVar.output_EPot
     EPot=nan(size(this.stateVar.basinMask));
    maskVar='EPot';
%     cmd=[cmd ' EPot'];
end
%/ MOADIFIED

for core=1:nCoresLS% mosiac and accumulation to the coarse time step
    [fileOutVar,subName]=StateVariables.GenerateOutVarNames(this.globalVar.resPathInit,...
        this.forcingVar.dateCur,this.globalVar.timeFormatLS,...
        this.forcingVar.fmtSubDir,this.forcingVar.pathSplitor,...
        core,nCoresLS);
    dirCore=fullfile(dirLocMosaicIn,[num2str(core),'_',num2str(nCoresLS)]);
    if exist(dirCore,'dir')~=7
        mkdir(dirCore);
    end
    if ~isempty(this.globalVar.resPathInitLoc)% copy the initial result file to a local directory     
        [~,name,ext]=fileparts(fileOutVar);
%         nameInt=[dirLocMosaicIn,this.forcingVar.pathSplitor,name,'_',num2str(core),'_',num2str(nCores),ext];
        nameInt=fullfile(dirCore,[name,ext]);
%         dirInt=[dirLocMosaicIn,this.forcingVar.pathSplitor,num2str(core),'_',num2str(nCoresLS),this.forcingVar.pathSplitor];
        if exist(nameInt,'file')~=2
            if ~isempty(this.oldResFile{core})
                delete(this.oldResFile{core});
%                 disp(['deleted ', this.oldResFile{core}]); 
            end
            % this.forcingVar.ioLocker.request();
            % this.forcingVar.ioLocker.checkPermission(false);
            copyfile(fileOutVar,nameInt);
            disp(['copied ' fileOutVar,' to ', nameInt]);
            % this.forcingVar.ioLocker.release();
        end
        this.oldResFile{core}=nameInt;
    else
        nameInt=fileOutVar;
    end
%     fileOutVar=StateVariables.GenerateOutVarNames(this.pathOutVar,this.forcingVar.dateCur,this.globalVar.timeFormat,core,nCores);
    maskCore=this.basicVar.multiCoreMasks==core;
    %% output variables of the land surface process
    cmd='S=load(nameInt,';
    for i=1:length(varListInFile)
        cmd=[cmd,'''',varListInFile{i},'_',subName,''','];
    end
    cmd(end)=[];
    cmd=[cmd,');'];
%     try % hornet gives me a hard time
        eval(cmd);
%     catch
%         disp('failed to execute the following command')
%         disp(cmd);
%         disp('deleted corrupted file')
%         delete(nameInt);
%         this.forcingVar.ioLocker.request();
%         this.forcingVar.ioLocker.checkPermission(false);
%         copyfile(fileOutVar,nameInt);
%         disp(['copied ' fileOutVar,' to ', nameInt, ' again']);
%         this.forcingVar.ioLocker.release();
%         eval(cmd);
%     end
    if strcmpi(maskVar,'W')
        cmd=['Wmem=S.',maskVar,'_',subName,';'];
        eval(cmd);
        tileMask=~isnan(Wmem(:,1));
    else
        cmdGetTileMask=['tileMask=~isnan(S.',maskVar,'_',subName,');'];
        eval(cmdGetTileMask);
    end
    
    if this.globalVar.output_Rain
        cmd=['rain(maskCore)=S.rain_',subName,'(tileMask);'];
        eval(cmd)
    end
    if this.globalVar.output_EAct
        cmd=['EAct(maskCore)=S.EAct_',subName,'(tileMask);'];
        eval(cmd);
    end
    if this.globalVar.output_Snow
        cmd=['snow(maskCore)=S.snow_',subName,'(tileMask);'];
        eval(cmd);
    end
    if this.globalVar.output_SWE
        cmd=['SWE(maskCore)=S.SWE_',subName,'(tileMask);'];
        eval(cmd);
    end
    if this.globalVar.output_intRain
        cmd=['intWater(maskCore)=S.intWater_',subName,'(tileMask);'];
        eval(cmd);
    end
    if this.globalVar.output_intSnow
        cmd=['intSnow(maskCore)=S.intSnow_',subName,'(tileMask);'];
        eval(cmd);
    end
%     this.stateVar.WSurf(this.stateVar.basinMask)=this.snowpack.W;
%     this.stateVar.WPack(this.stateVar.basinMask)=this.snowpack.WPack;
%     [~,this.stateVar.iceSurf(this.stateVar.basinMask),this.stateVar.icePack(this.stateVar.basinMask)]=getIce(this.snowpack);
%     this.stateVar.CCSurf(this.stateVar.basinMask)=this.snowpack.CCSurf;
%     this.stateVar.CCPack(this.stateVar.basinMask)=this.snowpack.CCPack;
    % land surface process related variables
    if this.globalVar.output_ExcS
        cmd=['excS(maskCore)=S.excS_',subName,'(tileMask);'];
        eval(cmd);
    end
    if this.globalVar.output_ExcI
        cmd=['excI(maskCore)=S.excI_',subName,'(tileMask);'];
        eval(cmd);
    end
    if this.globalVar.output_rainBare
        cmd=['rainBare(maskCore)=S.rainBare_',subName,'(tileMask);'];
        eval(cmd);
    end 
%/RAINBARE
    if this.globalVar.output_actTranspir
        for iL=1:this.modelPar.nLayers
            iT=actTranspir(:,:,iL);
            cmd=['iTt=S.actTranspir_',subName,'(:,iL);'];
            eval(cmd);
            cmd='iT(maskCore)=iTt(tileMask);';
            eval(cmd);
            actTranspir(:,:,iL)=iT;
        end
    end 
%/ actTranspir
    if this.globalVar.output_EPot
        cmd=['EPot(maskCore)=S.EPot_',subName,'(tileMask);'];
        eval(cmd);
    end 
%/ EPot
    if this.globalVar.output_W
        for iL=1:this.modelPar.nLayers
            iW=W(:,:,iL);
            cmd=['iWw=S.W_',subName,'(:,iL);'];
            eval(cmd);
            cmd='iW(maskCore)=iWw(tileMask);';
            eval(cmd);
            W(:,:,iL)=iW;
        end
    end
    clear S
end
%% aggregate to the current coarse time line
if this.globalVar.output_Rain %aggregate
    this.stateVar.rain(this.stateVar.basinMask)=...
        this.stateVar.rain(this.stateVar.basinMask)+rain(this.stateVar.basinMask);
end
if this.globalVar.output_rainBare %aggregate
    this.stateVar.rainBare(this.stateVar.basinMask)=...
        this.stateVar.rainBare(this.stateVar.basinMask)+rainBare(this.stateVar.basinMask);
end
%/RAINBARE
if this.globalVar.output_actTranspir %aggregate
    this.stateVar.actTranspir(this.stateVar.basinMask)=...
        this.stateVar.actTranspir(this.stateVar.basinMask)+actTranspir(this.stateVar.basinMask);
end
%/actTranspir 
if this.globalVar.output_EPot %aggregate
    this.stateVar.EPot(this.stateVar.basinMask)=...
        this.stateVar.EPot(this.stateVar.basinMask)+EPot(this.stateVar.basinMask);
end
%/Epot 
if this.globalVar.output_Snow %aggregate
    this.stateVar.snow(this.stateVar.basinMask)=...
        this.stateVar.snow(this.stateVar.basinMask)+snow(this.stateVar.basinMask);
end
if this.globalVar.output_SWE %aggregate
    this.stateVar.SWE(this.stateVar.basinMask)=...
        (this.stateVar.SWE(this.stateVar.basinMask)*(this.forcingVar.nAgger-1)+SWE(this.stateVar.basinMask))/this.forcingVar.nAgger;
end
if this.globalVar.output_intRain %average
    this.stateVar.intRain(this.stateVar.basinMask)=...
        (this.stateVar.intRain(this.stateVar.basinMask)*(this.forcingVar.nAgger-1)+intWater(this.stateVar.basinMask))/this.forcingVar.nAgger;
end
if this.globalVar.output_intSnow %average
    this.stateVar.intSnow(this.stateVar.basinMask)=...
        (this.stateVar.intSnow(this.stateVar.basinMask)*(this.forcingVar.nAgger-1)+intSnow(this.stateVar.basinMask))/this.forcingVar.nAgger;
end
if this.globalVar.output_EAct %aggregate
    this.stateVar.EAct(this.stateVar.basinMask)=...
        this.stateVar.EAct(this.stateVar.basinMask)+EAct(this.stateVar.basinMask);
end
if this.globalVar.output_ExcS %aggregate
     this.stateVar.excS(this.stateVar.basinMask)=...
        this.stateVar.excS(this.stateVar.basinMask)+excS(this.stateVar.basinMask);
end
if this.globalVar.output_ExcI %aggregate
    this.stateVar.excI(this.stateVar.basinMask)=...
        this.stateVar.excI(this.stateVar.basinMask)+excI(this.stateVar.basinMask);
end
if this.globalVar.output_W %average
    this.stateVar.W0=(this.stateVar.W0*(this.forcingVar.nAgger-1)+W)/this.forcingVar.nAgger;
end
end