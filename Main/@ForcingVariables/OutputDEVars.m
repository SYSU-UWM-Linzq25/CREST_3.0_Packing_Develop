function OutputDEVars(this,varNames,varMats)
    
nVar=length(varNames);
if exist('core','var') && exist('nCores','var')
    [fileOutVarLoc,subName]=StateVariables.GenerateOutVarNames(this.globalVar.resPathInitLoc,...
        this.forcingVar.dateCur,this.globalVar.timeFormatRouting,...
        this.forcingVar.fmtSubDir,this.forcingVar.pathSplitor,core,nCores);
else
    [fileOutVarLoc,subName]=StateVariables.GenerateOutVarNames(this.globalVar.resPathInit,...
        this.forcingVar.dateCur,this.globalVar.timeFormatLS,...
        this.forcingVar.fmtSubDir,this.forcingVar.pathSplitor);
end
for iVar=1:nVar
    iSubName=[varNames{iVar},subName];
    cmd=[iSubName,'=varMats{iVar};'];
    eval(cmd);
    if exist(fileOutVarLoc,'file')==2
        cmd=['save ',fileOutVar, ' ', iSubName ' -append'];
    else
        cmd=['save ',fileOutVarLoc, ' ', iSubName ' -v7.3'];
    end
    eval(cmd);
end
end