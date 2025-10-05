function saveChkPt(this,core,nCores)
%% modified by Shen, X in 2019/7/1
if strcmpi(this.globalVar.runStyle,'forecast') || strcmpi(this.globalVar.runStyle,'analysis')
    fmtChkPt=this.globalVar.timeFormatLS;
else
    fmtChkPt=this.forcingVar.fmtSubDir;
end
if exist('core','var') && exist('nCores','var')
%     fileChkPt=StateVariables.GenerateOutVarNames(this.globalVar.resPathChkPts,...
%         this.forcingVar.dateCur,this.globalVar.timeFormatLS,...
%         this.forcingVar.fmtSubDir,this.forcingVar.pathSplitor,...
%         core,nCores);
      fileChkPt=StateVariables.GenerateOutVarNames(this.globalVar.resPathChkPts,...
        this.forcingVar.dateCur,this.globalVar.timeFormatLS,...
        fmtChkPt,this.forcingVar.pathSplitor,...
        core,nCores);
else
    fileChkPt=StateVariables.GenerateOutVarNames(this.globalVar.resPathChkPts,...
        this.forcingVar.dateCur,this.globalVar.timeFormatLS,...
        this.forcingVar.fmtSubDir,this.forcingVar.pathSplitor);
end
soilSurf=this.soilSurf;
snowpack=this.snowpack;
canopy=this.canopy;
save(fileChkPt,'soilSurf','canopy','snowpack');
disp(['check point on ' datestr(this.forcingVar.dateCur) ' saved.']);
end