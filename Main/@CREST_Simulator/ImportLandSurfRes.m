function ImportLandSurfRes(this,nCoresLS,varListInFile)
%% modification history
% updated by Shen, Xinyi in April, 2016
% local folders are used for inital reading and writing and monthly file
%% save the aggregated result on the last date and reset state varialbes
% reset the imported variables to zero if it is a new date(coarse)
dirLocMosaic=[this.globalVar.resPathInitLoc,'mosaic'];
dirLocMosaicIn=[dirLocMosaic,this.forcingVar.pathSplitor,'in'];

if this.globalVar.output_intRain
    intWater=nan(size(this.stateVar.basinMask));
    maskVar='intRain';
end
if this.globalVar.output_intSnow
    intSnow=nan(size(this.stateVar.basinMask));
    maskVar='intSnow';
end
if this.globalVar.output_W
    W=nan([size(this.stateVar.basinMask),this.modelPar.nLayers]);
    maskVar='W';
end
if this.globalVar.output_Rain
    rain=nan(size(this.stateVar.basinMask));
    maskVar='rain';
end
if this.globalVar.output_SM
    SM=nan(size(this.stateVar.basinMask));
    maskVar='SM';
end
if this.globalVar.output_Snow
    snow=nan(size(this.stateVar.basinMask));
    maskVar='snow';
end
if this.globalVar.output_EAct
    EAct=nan(size(this.stateVar.basinMask));
    maskVar='EAct';
end
if this.globalVar.output_SWE
    SWE=nan(size(this.stateVar.basinMask));
    maskVar='SWE';
end
if this.globalVar.output_ExcS
    excS=nan(size(this.stateVar.basinMask));
    maskVar='excS';
end
if this.globalVar.output_ExcI
    excI=nan(size(this.stateVar.basinMask));
    maskVar='excI';
end
if this.globalVar.output_rainBare
    rainBare=nan(size(this.stateVar.basinMask));
    maskVar='rainBare';
end
%/ MOADIFIED
if this.globalVar.output_actTranspir
    actTranspir=nan([size(this.stateVar.basinMask),3]);
    maskVar='actTranspir';
end
%/ MOADIFIED
if this.globalVar.output_EPot
    EPot=nan(size(this.stateVar.basinMask));
    maskVar='EPot';
end

%/ MOADIFIED
for core=1:nCoresLS% mosiac and accumulation to the coarse time step
    [fileOutVar,subName]=StateVariables.GenerateOutVarNames(this.globalVar.resPathInit,...
        this.forcingVar.dateCur,this.globalVar.timeFormatLS,...
        this.forcingVar.fmtSubDir,this.forcingVar.pathSplitor,...
        core,nCoresLS);
    % if ~isempty(this.globalVar.resPathInitLoc)% copy the initial result file to a local directory
    %     [~,name,ext]=fileparts(fileOutVar);
    %     nameInt=[dirLocMosaicIn,this.forcingVar.pathSplitor,num2str(core),'_',num2str(nCoresLS),this.forcingVar.pathSplitor,name,ext];
    %     if exist(nameInt,'file')~=2
    %         if ~isempty(this.oldResFile{core})
    %             delete(this.oldResFile{core});
    %         end
    %         copyfile(fileOutVar,nameInt);
    %         disp(['copied ' fileOutVar,' to ', nameInt]);
    %     end
    %     this.oldResFile{core}=nameInt;
    % else
    %     nameInt=fileOutVar;
    % end
    %     fileOutVar=StateVariables.GenerateOutVarNames(this.pathOutVar,this.forcingVar.dateCur,this.globalVar.timeFormat,core,nCores);
    maskCore=this.basicVar.multiCoreMasks==core;
    %% output variables of the land surface process
    cmd='S=load(fileOutVar,';
    for i=1:length(varListInFile)
        cmd=[cmd,'''',varListInFile{i},'_',subName,''','];
    end
    cmd(end)=[];
    cmd=[cmd,');'];
    eval(cmd);

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
    if this.globalVar.output_SM
        cmd=['SM(maskCore)=S.SM_',subName,'(tileMask);'];
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
    % land surface process related variables
    if this.globalVar.output_ExcS
        cmd=['excS(maskCore)=S.excS_',subName,'(tileMask);'];
        eval(cmd);
        fL = ['excS_lake_', subName];
        if isfield(S, fL)
            cmd=['excS_lake(maskCore)=S.excS_lake_',subName,'(tileMask);'];
            eval(cmd);
        end
    end
    if this.globalVar.output_ExcI
        cmd=['excI(maskCore)=S.excI_',subName,'(tileMask);'];
        eval(cmd);
        fL = ['excI_lake_', subName];
        if isfield(S, fL)
            cmd=['excI_lake(maskCore)=S.excI_lake_',subName,'(tileMask);'];
            eval(cmd);
        end
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
if this.globalVar.output_SM %aggregate
    this.stateVar.SM(this.stateVar.basinMask)=...
        this.stateVar.SM(this.stateVar.basinMask)+SM(this.stateVar.basinMask);
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
