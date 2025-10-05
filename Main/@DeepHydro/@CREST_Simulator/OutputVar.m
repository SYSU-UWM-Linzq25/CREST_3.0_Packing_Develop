function error=OutputVar(this,checkMassBal,core,nCores)
global has1stTS
if exist('core','var') && exist('nCores','var')
    [fileOutVar,subName]=StateVariables.GenerateOutVarNames(this.globalVar.resPathInitLoc,...
        this.forcingVar.dateCur,this.globalVar.timeFormatLS,...
        this.forcingVar.fmtSubDir,this.forcingVar.pathSplitor,core,nCores);
else
    [fileOutVar,subName]=StateVariables.GenerateOutVarNames(this.globalVar.resPathInit,...
        this.forcingVar.dateCur,this.globalVar.timeFormatLS,...
        this.forcingVar.fmtSubDir,this.forcingVar.pathSplitor);
end
% if exist(fileOutVar,'file')==2
%     outvar=matfile(fileOutVar,'Writable',true);
% else
%     save(fileOutVar,'-v7.3');
% end

if checkMassBal
    excS=this.soilSurf.ExcS;
    excI=this.soilSurf.ExcI;
    rain=this.rain;
    snow=this.snow;
    EAct=this.EAct;
    SWE=this.snowpack.swqTotal;
    dSWE=SWE-this.stateVar.SWE(this.stateVar.basinMask);
    this.stateVar.SWE(this.stateVar.basinMask)=SWE;
    intWater=zeros(this.nCells,1);
    intWater(this.soilSurf.isOverstory)=this.canopy.W;
    intWater=intWater+this.soilSurf.WVeg;
    dIntRain=intWater-this.stateVar.intRain(this.stateVar.basinMask);
    this.stateVar.intRain(this.stateVar.basinMask)=intWater;
    intSnow=zeros(this.nCells,1);
    intSnow(this.soilSurf.isOverstory)=this.canopy.intSnow;
    dIntSnow=intSnow-this.stateVar.intSnow(this.stateVar.basinMask);
    this.stateVar.intSnow(this.stateVar.basinMask)=intSnow;
    W=this.soilSurf.W;
    dW=0;
    dDrip=zeros(this.nCells,1);
    dDrip(this.soilSurf.isOverstory)=this.canopy.rainDrip+this.canopy.snowDrip-this.drip;
    for iL=1:this.soilSurf.nLayers
        W0L=this.stateVar.W0(:,:,iL);
        dW=dW+W(:,iL)-W0L(this.stateVar.basinMask);
        W0L(this.stateVar.basinMask)=W(:,iL);
        this.stateVar.W0(:,:,iL)=W0L;
    end
%     errorMat=sum(this.soilSurf.Wm,2);
    errorMat=(rain+snow)-(EAct+dSWE+dIntRain+dIntSnow+dDrip+dW+excS+excI);
%     errorMat=(rain+snow)-(EAct+dSWE+dIntRain+dIntSnow+this.rainBare);
% %     errorMat=this.rainBare-(dW+excS+excI);
     [~,mErr]=max(abs(errorMat(:)));
    error=errorMat(mErr);
else
    varListInFile={};
    varListInMem={};
    
    if this.globalVar.output_ExcS
        varListInFile{end+1}='excS';
        varListInMem{end+1}='this.soilSurf.ExcS';
%         excS=this.soilSurf.ExcS;
%         cmd= [cmd ,' excS'];
    end
%     cmd=['save ' fileOutVar];
    if this.globalVar.output_ExcI
        varListInFile{end+1}='excI';
        varListInMem{end+1}='this.soilSurf.ExcI';
%         excI=this.soilSurf.ExcI;
%         cmd= [cmd ,' excI'];
    end
    if this.globalVar.output_rainBare
        varListInFile{end+1}='rainBare';
        varListInMem{end+1}='this.rainBare';
%         this.rainBare=this.rainBare;
%         cmd= [cmd ,' rainBare'];
    end
%/MODIFIED
    if this.globalVar.output_actTranspir
        varListInFile{end+1}='actTranspir';
        varListInMem{end+1}='this.actTranspir';
%          actTranspir=this.actTranspir;
%         cmd= [cmd ,' actTranspir'];
    end
%/MODIFIED
    if this.globalVar.output_EPot
        varListInFile{end+1}='EPot';
        varListInMem{end+1}='this.PET';
    end
%/MODIFIED
    if this.globalVar.output_Rain
        varListInFile{end+1}='rain';
        varListInMem{end+1}='this.rain';
%         rain=this.rain;
%         cmd= [cmd ,' rain'];
    end
    if this.globalVar.output_Snow
        varListInFile{end+1}='snow';
        varListInMem{end+1}='this.snow';
%         snow=this.snow;
%         cmd= [cmd ,' snow'];
    end
    if this.globalVar.output_EAct
        varListInFile{end+1}='EAct';
        varListInMem{end+1}='this.EAct';
    end
    if this.globalVar.output_SWE
        varListInFile{end+1}='SWE';
        varListInMem{end+1}='this.snowpack.swqTotal';
    end
   
    if this.globalVar.output_W
        varListInFile{end+1}='W';
        varListInMem{end+1}='this.soilSurf.W';
    end
    
    if this.globalVar.output_intRain
        intWater=zeros(this.nCells,1);
        intWater(this.soilSurf.isOverstory)=this.canopy.W;
        intWater=intWater+this.soilSurf.WVeg;
        varListInFile{end+1}='intWater';
        varListInMem{end+1}='intWater';
    end
    if this.globalVar.output_intSnow
        intSnow=zeros(this.nCells,1);
        intSnow(this.soilSurf.isOverstory)=this.canopy.intSnow;
        varListInFile{end+1}='intSnow';
        varListInMem{end+1}='intSnow';
    end
    
    for i=1:length(varListInFile)
        cmd=[varListInFile{i},'_',subName,'=',varListInMem{i},';'];
        eval(cmd)
    end
    varStr=cell(2,length(varListInFile));
    varStr(1,:)=varListInFile;
    varStr(2,:)={['_',subName,' ']};
    varStr=reshape(varStr,1,2*length(varListInFile));
    varStr=[varStr{:}];
    if exist(fileOutVar,'file')==2
%         S=matfile(fileOutVar,'Writable',true);
%         for i=1:length(varListInFile)
%             cmd=['S.',varListInFile{i},'_',subName,'=',varListInMem{i},';'];
%             eval(cmd);
%         end
%         clear S
        cmd=['save ',fileOutVar, ' ', varStr ' -append'];
    else
        % deal with the last file
        if has1stTS
            if (~isempty(this.oldResFile)) && exist('core','var') && exist('nCores','var')
                % this.forcingVar.ioLocker.request();
                % this.forcingVar.ioLocker.checkPermission();
                disp('moving result file from local to external folder');
                movefile(this.oldResFile,[this.coreDir,this.forcingVar.pathSplitor],'f');
                % this.forcingVar.ioLocker.release();
            end
        else
            disp('the result file of the last time step is not saved because not all time steps are contained');
            delete(this.oldResFile);
        end
        [~,fileIntWithoutDir,~]=fileparts(fileOutVar);
        fileNameInt=[this.coreDir,this.forcingVar.pathSplitor,fileIntWithoutDir,'.mat'];
        fileOutVarPrev=StateVariables.GenerateOutVarNames(this.globalVar.resPathInitLoc,...
            this.forcingVar.dateCur-this.forcingVar.timeStep,this.globalVar.timeFormatLS,...
            this.forcingVar.fmtSubDir,this.forcingVar.pathSplitor,core,nCores);
        if (strcmpi(fileOutVarPrev,fileOutVar)~=1) || strcmpi(this.globalVar.runStyle,'forecast')% indicates that the file will be complete of all time steps
            has1stTS=true;
            cmd=['save ',fileOutVar, ' ', varStr ' -v7.3'];
        elseif strcmpi(fileOutVarPrev,fileOutVar)==1 && strcmpi(this.globalVar.runStyle,'analysis') && exist(fileNameInt,'file')
            disp('Detected existing result file from previous simulation.')
            disp('copying...')
            % this.forcingVar.ioLocker.request();
            % this.forcingVar.ioLocker.checkPermission();
            copyfile(fileNameInt,fileOutVar);
            % this.forcingVar.ioLocker.release();
            cmd=['save ',fileOutVar, ' ', varStr ' -append'];
            has1stTS=true;
        else
            has1stTS=false;
        end
        % deal with the first time step in the new(current) file
        this.oldResFile=fileOutVar;
    end
    eval(cmd);
end
end