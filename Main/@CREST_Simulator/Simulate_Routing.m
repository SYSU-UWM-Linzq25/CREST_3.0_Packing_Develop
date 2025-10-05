function [NSCE,tElapse]=Simulate_Routing(this,x0,keywords)
%% major updates
% Mar. 2, 2017, intermittant event mode is added back by Shen. X
try
moveBack=false;
if nargin==3
    mode='calib';
else
    mode='simu';
end
tic
if strcmpi(mode,'calib')
%                 bCalib=true;
    define_constant();
    this.ModelParInit([],[],x0,keywords);
else
    this.ModelParInit();
end
this.stateVar.preset(this.basicVar.lake);
this.forcingVar.reset(mode,this.globalVar.taskType,moveBack,0,0);
if this.globalVar.toLoad
    fileLoad=[this.globalVar.statePath,'RoutingStatus',this.forcingVar.pathSplitor,...
                 datestr(this.forcingVar.dateCur,this.globalVar.timeFormatRoute),'.mat'];
    this.stateVar.LoadModelStates(fileLoad);
    this.forcingVar.MoveNext(mode,this.globalVar.taskType);
end
if ~strcmpi(this.globalVar.taskType,'Routing')
    this.presetMedium();
    this.stateVar.reset(this.soilSurf.nLayers,this.globalVar.taskType);    
else
    this.stateVar.reset([],this.globalVar.taskType);    
end   
bEnd=false;
timeOfStep=1;

while(~bEnd)
    if ~strcmpi(mode,'calib')
        disp(datestr(this.forcingVar.dateCur,'yyyy/mm/dd:HH:MM'))
    end
    this.LoadDirectRunoff();
    this.WaterBudgetUpdate();
    this.StateVarUpdate();
    this.DownstreamRoute();
    this.stateVar.CalculateOutletData(timeOfStep,strcmpi(mode,'calib'),this.basicVar.masks);
    if ~strcmpi(mode,'calib')
        %% save runoff images
        if this.globalVar.output_runoff
            this.stateVar.OutputVar(this.forcingVar.dateCur,this.forcingVar.timeFormat,this.forcingVar.fmtSubDir,[this.globalVar.resPathEx,'R.']);
        end
        %% save model state variables for event routing
        if this.globalVar.toSave
            if ismember(this.forcingVar.dateCur,this.globalVar.saveDates)
                dirRouteStatus=[this.globalVar.statePath,'RoutingStatus',this.forcingVar.pathSplitor];
                if exist(dirRouteStatus,'dir')~=7
                    mkdir(dirRouteStatus);
                end
                dateToSave=datestr(this.forcingVar.dateCur+this.globalVar.saveOffset,this.globalVar.saveDateFormat);
                this.stateVar.SaveModelStates([dirRouteStatus,dateToSave,'.mat']);
            end
        end
    end
    %% move to the next time step
    timeOfStep=timeOfStep+1;
    bEnd=~this.forcingVar.MoveNext(mode,this.globalVar.taskType);
    %% if the mode is intermediate event running
    if bEnd 
         bEnd=this.forcingVar.reset(mode,this.globalVar.taskType,moveBack,0,0);
         if bEnd
             continue;
         end
         fileLoad=[this.globalVar.statePath,'RoutingStatus',this.forcingVar.pathSplitor,...
                 datestr(this.forcingVar.dateCur,this.globalVar.timeFormatRoute),'.mat']; 
%          moisture and other status are not needed to be loaded
         this.stateVar.reset([],this.globalVar.taskType);
         this.stateVar.LoadModelStates(fileLoad);
         this.forcingVar.MoveNext(mode,this.globalVar.taskType);
         if ~strcmpi(mode,'calib') && this.globalVar.toLoad
             disp(['Saved Status is loaded on ', datestr(this.forcingVar.dateCur),'.']);
         end
     end
end
tElapse=toc;
if ~strcmpi(mode,'calib')
    disp(['total simulation time: ' num2str(tElapse) 'seconds']);
    [NSCE,Bias,CC]=this.stateVar.GetSingleObjNSCE();
    disp(strcat('NSCE=',num2str(NSCE)))
    disp(strcat('Bias=',num2str(Bias)))
    disp(strcat('CC=  ',num2str(CC)));
else %calibration mode
    if strcmpi(this.globalVar.taskType,'Routing')
        NSCE=this.stateVar.GetSingleObjNSCE();
    else
        NSCE=NaN;
    end
end

catch ME
    NSCE=NaN;
    tElapse=-9999;
    excFile=[this.globalVar.resPathEx,'err.txt'];
    fid=fopen(excFile);
    msgText=ME.getReport();
    fprintf(fid,'%s\n',msgText);
    fprintf(fid,'%f',x0);
    fclose(fid);
end
end