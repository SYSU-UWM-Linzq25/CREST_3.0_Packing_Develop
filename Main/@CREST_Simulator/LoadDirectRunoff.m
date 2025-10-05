function LoadDirectRunoff(this)
%% 1) updated by Shen X. to add forecast in Oct. 2019
%% load direct runoff for the entire basin
[fileOutVarFinal,subDate]=StateVariables.GenerateOutVarNames(this.globalVar.resPathAgger,...
    this.forcingVar.dateCur,this.globalVar.timeFormatRoute,...
    this.forcingVar.fmtSubDir,this.forcingVar.pathSplitor);
if exist(fileOutVarFinal,'file')==2
    bLoadedCur=false;
    oldDate=this.forcingVar.dateCur;
    while ~bLoadedCur
        subNameExcS=['excS_',subDate];
        subNameExcI=['excI_',subDate];
        subNameSWE=['SWE_',subDate];
        subNamerain=['rain_',subDate];
        subNameSM=['SM_',subDate];
        try
            %S = load(fileOutVarFinal);
            S=load(fileOutVarFinal,subNameExcS,subNameExcI,subNameSWE,subNamerain,subNameSM);
            this.stateVar.SWE=S.(subNameSWE);
            %% load only the direct runoff in grids with no snow pack
            noSWE=(this.stateVar.SWE<=0);
            this.stateVar.excS=S.(subNameExcS).*noSWE;
        %     eval(cmd);
            this.stateVar.excI=S.(subNameExcI).*noSWE;
            if this.globalVar.output_SM
                %S=load(fileOutVarFinal,subNameSM);
                this.stateVar.SM=S.(subNameSM);
            end
            if this.globalVar.output_Rain
                %S=load(fileOutVarFinal,subNamerain);
                this.stateVar.rain=S.(subNamerain);
            end
            bLoadedCur=true;
        catch
            warning(['missing land surface results on ' datestr(this.forcingVar.dateCur,'yyyy-mm-dd HH:MM')]);
            oldDate=ForcingVariables.addDatenum(oldDate,-this.forcingVar.timeStep);
            [fileOutVarFinal,subDate]=StateVariables.GenerateOutVarNames(this.globalVar.resPathAgger,...
                oldDate,this.globalVar.timeFormatRoute,...
                this.forcingVar.fmtSubDir,this.forcingVar.pathSplitor);
            disp(['loading ', datestr(oldDate,'yyyy-mm-dd HH:MM')]);            
        end
    end
%     eval(cmd);
%     cmd=['clear ',subNameExcS,' ',subNameExcI];
%     eval(cmd);
    %% load the direct runoff in grids with snow pack on a previous date
    del=this.modelPar.delay(this.stateVar.basinMask);
    del=del(1);
    del=round(del);
    bReadPrev=false;
    datePrev=ForcingVariables.addDatenum(this.forcingVar.dateCur,-del*this.forcingVar.timeStep);
    % do not retrospect if the previous data is before the starting date
    if datePrev<this.forcingVar.dateStart %&& (strcmpi(this.globalVar.runStyle,'analysis')~=1)...
           % && (strcmpi(this.globalVar.runStyle,'forecast')~=1)
        bReadPrev=true;
    end
    while ~bReadPrev
        %% begin 1)
        if this.forcingVar.isFore
            [fileOutVarPrev,subDatePrev]=StateVariables.GenerateOutVarNames(this.globalVar.resPathAgger2,...
            datePrev,this.globalVar.timeFormatRoute,...
            this.forcingVar.fmtSubDir,this.forcingVar.pathSplitor);
        else
            [fileOutVarPrev,subDatePrev]=StateVariables.GenerateOutVarNames(this.globalVar.resPathAgger,...
            datePrev,this.globalVar.timeFormatRoute,...
            this.forcingVar.fmtSubDir,this.forcingVar.pathSplitor);
        end
%         [fileOutVarPrev,subDatePrev]=StateVariables.GenerateOutVarNames(this.globalVar.resPathAgger,...
%             datePrev,this.globalVar.timeFormatRoute,...
%             this.forcingVar.fmtSubDir,this.forcingVar.pathSplitor); 
       %% end 1)
        if exist(fileOutVarPrev,'file')==2
            subNameExcSPrev=['excS_',subDatePrev];
            subNameExcIPrev=['excI_',subDatePrev];
            subNameSWEPrev=['SWE_',subDatePrev];
            try
                S = load(fileOutVarPrev,subNameExcSPrev,subNameExcIPrev,subNameSWEPrev);
                %S = load(fileOutVarPrev);
                SWEPrev=S.(subNameSWEPrev);
                hasSWEPrev=(SWEPrev>0);
                this.stateVar.excS=this.stateVar.excS+S.(subNameExcSPrev).*hasSWEPrev;
            %     eval(cmd);
                this.stateVar.excI=this.stateVar.excI+S.(subNameExcIPrev).*hasSWEPrev;
            %     eval(cmd);
            %     cmd=['clear ',subNameExcS,' ',subNameExcI];
            %     eval(cmd);
                 %% scale direct runoff
                this.stateVar.excS(this.stateVar.basinMask)=this.stateVar.excS(this.stateVar.basinMask).*...
                    this.modelPar.fExcS(this.stateVar.basinMask);
                this.stateVar.excI(this.stateVar.basinMask)=this.stateVar.excI(this.stateVar.basinMask).*...
                    this.modelPar.fExcI(this.stateVar.basinMask);
                bReadPrev=true;
            catch
                warning(['missing land surface results on ' datestr(datePrev,'yyyy-mm-dd HH:MM')]);
                datePrev=ForcingVariables.addDatenum(datePrev,-this.forcingVar.timeStep);
                disp(['loading ', datestr(datePrev,'yyyy-mm-dd HH:MM')]);                
            end
        end
    end
else
    error(['missing land surface result on' datestr(this.forcingVar.dateCur)])
end
end

