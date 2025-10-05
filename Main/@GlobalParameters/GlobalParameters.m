classdef GlobalParameters<handle
%% updated by Shen, Xinyi, Aug., 2015
% routing becomes a optional module
%
%% updated by Shen, Xinyi, Jul., 2015 (CRESTv3.0)
% forcing control is moved to a separated file in the forcing folder
%% written by Shen, Xinyi, Jun., 2014 (CRESTv2.1)
% xinyi.shen@uconn.edu
    properties
        timeFormatLS;timeMarkLS;timeStepLS;timeStepInMLS;nTimeStepsLS;
        startDateLS;%numOfLoaded;
        warmupDateLS;endDateLS;
        
        timeFormatRoute;timeMarkRoute;timeStepRoute;timeStepInMRoute;nTimeStepsRoute;
        startDateRoute;warmupDateRoute;endDateRoute;
        
        saveState;
        taskType;
        node;numOfNodes;
        runStyle;
        feedback;
        autoClip;
        hasRiverInterflow;
        basicFormat;basicPath;basicPathExt;DEMExt;FDRExt;FACExt;streamExt;
        paramPath;statePath;ICSPath;
        forcingCtl;
        obsPath;calibPath;calibMode;
        obsFormat;obsDateConvetion;obsNoData;
        resPathInitLoc;resPathInit;resPathMosaic;resPathAgger;resPathDeepLS;resPathAgger2;resPathVal;resPathEx;resPathNodeMasks;resPathChkPts;
        nSites;
        STCD;
        px_lat;
        px_lon;
        hasOutlet;
        out_STCD;
        out_shp;
        eventMode;
        FEDB;
        
        output_Rain;
        output_Snow;
        output_EPot;
        output_EAct;
        output_runoff;
        output_W;
        output_SM;
        output_ExcS;
        output_ExcI;
        output_RS;
        output_RI;
        output_SWE;
        output_intRain;
        output_intSnow;
        output_rainBare; %/MODIFIED
        output_actTranspir; %/MODIFIED
        toLoad=false;
        toSave=false;
        saveDates;
        saveDateFormat;
        saveOffset;
        decompBeforeSrc;
        decompBeforeDst;
        OS;
        
        optBlowSnow=true;
    end
    methods
        function obj=GlobalParameters(gFile)
           gfileID = fopen(gFile);
           commentSymbol='#';
           obj.OS=GlobalParameters.readLine(gfileID,'OS',commentSymbol,'string');
           [obj.timeMarkLS,obj.timeFormatLS,obj.timeStepInMLS,obj.timeStepLS,obj.nTimeStepsLS,obj.startDateLS,obj.warmupDateLS,obj.endDateLS]=...
               GlobalParameters.ReadTimeLine(gfileID,commentSymbol,...
               'TimeMarkLS','TimeFormatLS','TimeStepLS','StartDateLS','WarmupDateLS','EndDateLS');
           csvLoadPts=GlobalParameters.readLine(gfileID,'LoadDates',commentSymbol,'string');
           if ~strcmpi(csvLoadPts,'')
               obj.toLoad=true;
               [obj.timeMarkRoute,obj.timeFormatRoute,obj.timeStepInMRoute,obj.timeStepRoute]=...
               GlobalParameters.ReadTimeLine(gfileID,commentSymbol,...
               'TimeMarkRoute','TimeFormatRoute','TimeStepRoute','StartDateRoute','WarmupDateRoute','EndDateRoute');
               
               disp('Contain Loading Dates');
           else
               [obj.timeMarkRoute,obj.timeFormatRoute,obj.timeStepInMRoute,obj.timeStepRoute,obj.nTimeStepsRoute,obj.startDateRoute,obj.warmupDateRoute,obj.endDateRoute]=...
               GlobalParameters.ReadTimeLine(gfileID,commentSymbol,...
               'TimeMarkRoute','TimeFormatRoute','TimeStepRoute','StartDateRoute','WarmupDateRoute','EndDateRoute');
           end
%           obj.numOfLoaded=GlobalParameters.readLine(gfileID,'NLoad',commentSymbol,'double');
%            obj.loadPts=GlobalParameters.readLine(gfileID,['WarmupDate_',num2str(i)],commentSymbol,'string');
%            if obj.numOfLoaded>0
%                strWarmupDate=cell(obj.numOfLoaded,1);
%                strEndDate=cell(obj.numOfLoaded,1);
%                for i=1:obj.numOfLoaded
%                    strWarmupDate{i}=GlobalParameters.readLine(gfileID,['WarmupDate_',num2str(i)],commentSymbol,'string');
%                    strEndDate{i}=GlobalParameters.readLine(gfileID,['EndDate_',num2str(i)],commentSymbol,'string');
%                end
%            else
%                strWarmupDateLS=GlobalParameters.readLine(gfileID,'WarmupDateLS',commentSymbol,'string');
%                strEndDateLS=GlobalParameters.readLine(gfileID,'EndDateLS',commentSymbol,'string');
%            end
           obj.runStyle=GlobalParameters.readLine(gfileID,'RunStyle',commentSymbol,'string');
           obj.taskType=GlobalParameters.readLine(gfileID,'TaskType',commentSymbol,'string');
           obj.feedback=GlobalParameters.readLine(gfileID,'Feedback',commentSymbol,'boolean');
           obj.hasRiverInterflow=GlobalParameters.readLine(gfileID,'hasRiverInterflow',commentSymbol,'boolean');
           obj.eventMode=GlobalParameters.readLine(gfileID,'EventMode',commentSymbol,'string');
           obj.basicFormat=GlobalParameters.readLine(gfileID,'BasicFormat',commentSymbol,'string');
           obj.autoClip=GlobalParameters.readLine(gfileID,'UseExtGeographic',commentSymbol,'boolean');
           if obj.autoClip
               obj.basicPathExt=GlobalParameters.readLine(gfileID,'BasicPathExt',commentSymbol,'string');
               obj.DEMExt=[obj.basicPathExt,GlobalParameters.readLine(gfileID,'DEMExt',commentSymbol,'string')];
               obj.FDRExt=[obj.basicPathExt,GlobalParameters.readLine(gfileID,'FDRExt',commentSymbol,'string')];
               obj.FACExt=[obj.basicPathExt,GlobalParameters.readLine(gfileID,'FACExt',commentSymbol,'string')];
               obj.streamExt=[obj.basicPathExt,GlobalParameters.readLine(gfileID,'streamExt',commentSymbol,'string')];
           end
          %% paths of the model
           obj.basicPath=GlobalParameters.readLine(gfileID,'BasicPathInt',commentSymbol,'string');
           obj.paramPath=GlobalParameters.readLine(gfileID,'ParamFile',commentSymbol,'string');
           obj.statePath=GlobalParameters.readLine(gfileID,'StatePath',commentSymbol,'string');
           obj.ICSPath=GlobalParameters.readLine(gfileID,'ICSPath',commentSymbol,'string');
          %% forcing control file
           obj.forcingCtl=GlobalParameters.readLine(gfileID,'ForcingFile',commentSymbol,'string');
           % result output
           obj.resPathInitLoc=GlobalParameters.readLine(gfileID,'ResultInitLoc',commentSymbol,'string');% this is a local directory
           obj.resPathInit=GlobalParameters.readLine(gfileID,'ResultInit',commentSymbol,'string');
           obj.resPathMosaic=GlobalParameters.readLine(gfileID,'ResultMosaic',commentSymbol,'string');
           
           obj.resPathAgger=GlobalParameters.readLine(gfileID,'ResultAgger',commentSymbol,'string');
           
           if strcmpi(obj.runStyle,'forecast') && strcmpi(obj.taskType,'routing')
               obj.resPathAgger2=GlobalParameters.readLine(gfileID,'ResultAgger2',commentSymbol,'string');
           end
           if strcmpi(obj.taskType,'DeepHydro_regrid')
               obj.resPathDeepLS=GlobalParameters.readLine(gfileID,'resultDeepLS',commentSymbol,'string');
           end
           obj.resPathVal=GlobalParameters.readLine(gfileID,'ResultVal',commentSymbol,'string');
           obj.resPathEx=GlobalParameters.readLine(gfileID,'ResultEx',commentSymbol,'string');
           obj.resPathNodeMasks=GlobalParameters.readLine(gfileID,'ResultMasks',commentSymbol,'string');
           obj.resPathChkPts=GlobalParameters.readLine(gfileID,'ResultChkPts',commentSymbol,'string');
           
           obj.calibPath=GlobalParameters.readLine(gfileID,'CalibPath',commentSymbol,'string');
           obj.calibMode=GlobalParameters.readLine(gfileID,'CalibMode',commentSymbol,'string');
           
           obj.obsFormat=GlobalParameters.readLine(gfileID,'OBSDateFormat',commentSymbol,'string');
           obj.obsPath=GlobalParameters.readLine(gfileID,'OBSPath',commentSymbol,'string');
           obj.obsNoData=GlobalParameters.readLine(gfileID,'OBSNoDataValue',commentSymbol,'double');
           obj.hasOutlet=GlobalParameters.readLine(gfileID,'HasOutlet',commentSymbol,'boolean');
           if obj.hasOutlet
               obj.out_STCD=GlobalParameters.readLine(gfileID,'OutletName',commentSymbol,'string');
           end
           if ~strcmpi(csvLoadPts,'')
               obj.loadSavePts(csvLoadPts,true);
           end
           obj.out_shp=[obj.obsPath,GlobalParameters.readLine(gfileID,'SitesShpFile',commentSymbol,'string')];
           obj.FEDB=GlobalParameters.readLine(gfileID,'DBFEName',commentSymbol,'string');
          %% grid output options
           obj.output_Rain=GlobalParameters.readLine(gfileID,'GOVar_Rain',commentSymbol,'boolean');
           obj.output_Snow=GlobalParameters.readLine(gfileID,'GOVar_Snow',commentSymbol,'boolean');
           obj.output_EPot=GlobalParameters.readLine(gfileID,'GOVar_EPot',commentSymbol,'boolean');
           obj.output_EAct=GlobalParameters.readLine(gfileID,'GOVar_EAct',commentSymbol,'boolean');
           obj.output_W=GlobalParameters.readLine(gfileID,'GOVar_W',commentSymbol,'boolean');
           obj.output_SM=GlobalParameters.readLine(gfileID,'GOVar_SM',commentSymbol,'boolean');
           obj.output_SWE=GlobalParameters.readLine(gfileID,'GOVar_SWE',commentSymbol,'boolean');
           obj.output_intRain=GlobalParameters.readLine(gfileID,'GOVar_intRain',commentSymbol,'boolean');
           obj.output_intSnow=GlobalParameters.readLine(gfileID,'GOVar_intSnow',commentSymbol,'boolean');
           obj.output_runoff=GlobalParameters.readLine(gfileID,'GOVar_R',commentSymbol,'boolean');
           obj.output_ExcS=GlobalParameters.readLine(gfileID,'GOVar_ExcS',commentSymbol,'boolean');
           obj.output_ExcI=GlobalParameters.readLine(gfileID,'GOVar_ExcI',commentSymbol,'boolean');
           obj.output_RS=GlobalParameters.readLine(gfileID,'GOVar_RS',commentSymbol,'boolean');
           obj.output_RI=GlobalParameters.readLine(gfileID,'GOVar_RI',commentSymbol,'boolean');
           obj.output_rainBare=GlobalParameters.readLine(gfileID,'GOVar_rainBare',commentSymbol,'boolean');
           obj.output_actTranspir=GlobalParameters.readLine(gfileID,'GOVar_actTranspir',commentSymbol,'boolean');
          %% resume mode option
           
%            nSaveDates=GlobalParameters.readLine(gfileID,'NumOfOutputDates',commentSymbol,'double');
%            obj.saveDates=zeros(nSaveDates,1);
           if ismember('linux',obj.OS)
               splitor='/';
           elseif ismember('windows',obj.OS)
               splitor='\';
           end
           csvSavePts=GlobalParameters.readLine(gfileID,'SaveDates',commentSymbol,'string');
           if ~strcmpi(csvSavePts,'')
               obj.toSave=true;
               obj.saveDateFormat=GlobalParameters.readLine(gfileID,'SaveDateFormat',commentSymbol,'string');
               obj.loadSavePts(csvSavePts,false);
               disp('Contain Saving Dates');
               obj.saveOffset=GlobalParameters.CalTimeInterval(...
               GlobalParameters.readLine(gfileID,'DateOffset',commentSymbol,'string'),obj.saveDateFormat,splitor);
           end
           
%            for i=1:nSaveDates
%                istrSaveDate=GlobalParameters.readLine(gfileID,['OutputDate_',num2str(i)],commentSymbol,'string');
%                obj.saveDates(i)=datenum(istrSaveDate,obj.timeFormat);
%            end
           obj.decompBeforeSrc=GlobalParameters.readLine(gfileID,'DecompBeforeSrc',commentSymbol,'string');
           obj.decompBeforeDst=GlobalParameters.readLine(gfileID,'DecompBeforeDst',commentSymbol,'string');
           fclose(gfileID);
        end
    end
    methods(Access=private)
        loadSavePts(this,csvPts,load);
    end
    methods(Static = true)
        [timeMark,timeFormat,timeStepInM,timeStep,nTimeSteps,startDate,warmupDate,endDate]=...
    ReadTimeLine(gfileID,commentSymbol,keyMark,keyTF,keyTS,keySD,keyWD,keyED);
        interval=CalTimeInterval(str,fmt,splitor);
        value=readLine(gfileID,keyword,commentSymbol,type);
        bValue=yesno2boolean(value);
        [dateForcStart,dateForcInter]=ForcingTimePar(strForcStart,strForcInter,fmt);
    end
end