function LoadDirectRunoff(this)
[fileOutVarFinal,subDate]=StateVariables.GenerateOutVarNames(this.globalVar.resPathAgger,...
    this.forcingVar.dateCur,this.globalVar.timeFormatRoute,...
    this.forcingVar.fmtSubDir,this.forcingVar.pathSplitor);
if ~isempty(this.globalVar.resPathInitLoc)
    [~,name,ext]=fileparts(fileOutVarFinal);
    locDir=[this.globalVar.resPathInitLoc,'in'];
    nameInt=[locDir,this.forcingVar.pathSplitor,name,ext];
    if exist(nameInt,'file')~=2
        if exist(fileOutVarFinal,'file')~=2
            error(['missing land surface result on' datestr(this.forcingVar.dateCur)])
        end
        if ~isempty(this.copiedLSFile)
            delete(this.copiedLSFile);
        end
        this.forcingVar.ioLocker.request();
        this.forcingVar.ioLocker.checkPermission(false);
        copyfile(fileOutVarFinal,nameInt);
        disp(['copied ' fileOutVarFinal,' to ', nameInt]);
        this.forcingVar.ioLocker.release();
    end
else
    nameInt=fileOutVar;
end

oldDate=this.forcingVar.dateCur;
subNameExcS=['excS_',subDate];
subNameExcI=['excI_',subDate];
subNameSWE=['SWE_',subDate];
try
    S=load(nameInt,subNameExcS,subNameExcI,subNameSWE);
    this.SWE=S.(subNameSWE);
    %% load only the direct runoff in grids with no snow pack
    noSWE=(this.SWE<=0);
    this.excS=S.(subNameExcS).*noSWE;
%     eval(cmd);
    this.excI=S.(subNameExcI).*noSWE;
    this.snowmeltExcI=S.(subNameExcI).*(~noSWE);
    this.snowmeltExcS=S.(subNameExcS).*(~noSWE);
    
catch% if the file is corrupted, load the previous time step
    warning(['missing land surface results on ' datestr(this.forcingVar.dateCur,'yyyy-mm-dd HH:MM')]);
    oldDate=ForcingVariables.addDatenum(oldDate,-this.forcingVar.timeStep);
    [fileOutVarFinal,subDate]=StateVariables.GenerateOutVarNames(this.globalVar.resPathAgger,...
        oldDate,this.globalVar.timeFormatRoute,...
        this.forcingVar.fmtSubDir,this.forcingVar.pathSplitor);
    subNameExcS=['excS_',subDate];
    subNameExcI=['excI_',subDate];
    subNameSWE=['SWE_',subDate];
    disp(['loading ', datestr(oldDate,'yyyy-mm-dd HH:MM')]);  
    S=load(fileOutVarFinal,subNameExcS,subNameExcI,subNameSWE);
    this.SWE=S.(subNameSWE);
    %% load only the direct runoff in grids with no snow pack
    noSWE=(this.SWE<=0);
    this.excS=S.(subNameExcS).*noSWE;
%     eval(cmd);
    this.excI=S.(subNameExcI).*noSWE;
    this.snowmeltExcI=S.(subNameExcI).*(~noSWE);
    this.snowmeltExcS=S.(subNameExcS).*(~noSWE);
end
this.copiedLSFile=nameInt;
end