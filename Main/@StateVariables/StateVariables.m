classdef StateVariables<RasterVariables
    properties        
        stream;
        Tdamp;% (o^C)unchanged soil temperature at very deep place
        W0; % soil moisture matrix in depth(mm)
        pW0;% soil moisture percentage (in %v)
        %current soil moisture(average soil moisture of the grid)
        SS0;% overland reservoir 
        SI0;% interflow reservoir
        bDistW0,bDistSS0,bDistSI0;bDistTdamp;
        
        excS; % excessive water overland
        excI; % excessive water underground
        EAct; % Actual ET
        RS;% surface runoff
        RI;% interflow runoff
        runoff;% total runoff
        rain% through fall
        snow;
        rainBare;%/ADD
        actTranspir;%/ADD
        intRain;
        intSnow;
        SWE;% snow water equivalence of the snow pack
        iceSurf;WSurf;CCSurf;
        icePack;WPack;CCPack;
        EPot;%/ADD
        %% output variables for simulation points
        px_rain;
        px_snow;
        px_SWE;
        px_intSnow;
        px_intRain;
        px_PET;
        px_EAct;
        px_W;
        px_SM;
        px_runoff;
        px_excS;px_excI;
        px_RS;px_RI;
        px_iceSurf;px_WSurf;px_CCSurf
        px_icePack;px_WPack;px_CCPack;
        timeStepInM;
        timeMark;
        %% observation
        hydroSites;
        %% files
        fileInit;
        bDistributedSoil;
       %% structures
        statesR;
    end
    methods
        function this=StateVariables(hSites,...
                timeMark,timeStepInM,...
                basinMask,streamMask,...
                fileInitCondDir,geoTrans,spatialRef,nLayers)
            %note that this a overloaded function
            %if the number of input is 1, the initial values from one
            %single file is read
            %else the initial values are read from separated asc(matrix) files
            %
            this=this@RasterVariables(geoTrans,spatialRef);
            this.hydroSites=hSites;
            [fileStateTXT,fileStateMat]=StateVariables.GenerateFileNames(fileInitCondDir);
            if exist(fileStateMat,'file')==2
                this.fileInit=fileStateMat;
                this.bDistributedSoil=true;
            elseif exist(fileStateTXT,'file')==2
                this.bDistributedSoil=false;
                this.fileInit=fileStateTXT;
            end
            this.timeMark=timeMark;
            this.timeStepInM=timeStepInM;
            this.basinMask=basinMask;
            this.stream=streamMask;
            this.InitStates(nLayers);
            this.px_excS=zeros(this.hydroSites.nTimeSteps,this.hydroSites.nSites);
            this.px_excI=zeros(this.hydroSites.nTimeSteps,this.hydroSites.nSites);
            this.px_rain=zeros(this.hydroSites.nTimeSteps,this.hydroSites.nSites);
            this.px_snow=zeros(this.hydroSites.nTimeSteps,this.hydroSites.nSites);
            this.px_SWE=zeros(this.hydroSites.nTimeSteps,this.hydroSites.nSites);
            this.px_PET=zeros(this.hydroSites.nTimeSteps,this.hydroSites.nSites);
            this.px_intRain=zeros(this.hydroSites.nTimeSteps,this.hydroSites.nSites);
            this.px_intSnow=zeros(this.hydroSites.nTimeSteps,this.hydroSites.nSites);
            this.px_EAct=zeros(this.hydroSites.nTimeSteps,this.hydroSites.nSites);
            this.px_W=zeros(this.hydroSites.nTimeSteps,this.hydroSites.nSites);
            this.px_SM=zeros(this.hydroSites.nTimeSteps,this.hydroSites.nSites);
            this.px_runoff=zeros(this.hydroSites.nTimeSteps,this.hydroSites.nSites);
            this.px_iceSurf=zeros(this.hydroSites.nTimeSteps,this.hydroSites.nSites);
            this.px_icePack=zeros(this.hydroSites.nTimeSteps,this.hydroSites.nSites);
            this.px_WSurf=zeros(this.hydroSites.nTimeSteps,this.hydroSites.nSites);
            this.px_WPack=zeros(this.hydroSites.nTimeSteps,this.hydroSites.nSites);
            this.px_CCSurf=zeros(this.hydroSites.nTimeSteps,this.hydroSites.nSites);
            this.px_CCPack=zeros(this.hydroSites.nTimeSteps,this.hydroSites.nSites);
        end
        preset(this,lake);
        reset(this,nLayers,taskType);
        CalculateOutletData(this,timeOfStep,bCalib,masks);
        OutputVar(this,curDate,fileFormat,subFormat,dirOut);
        SaveStates(this,resPath);
        SaveModelStates(this,strDateCur);
        LoadModelStates(this,strDateLoad);
        [NSCE,Bias,CC]=GetSingleObjNSCE(this);
        genHydrograph(this,resPath,dateStart);
    end
    methods (Static)
        [fileStateTXT,fileStateMat]=GenerateFileNames(dirState);
        [fileName,subName]=GenerateExpVarNames(dir,date,filefmt,subfmt);
        [fileOutVar,subName]=GenerateOutVarNames(dir,date,datefmt,fmtSubDir,splitor,core,nCores);
    end
end