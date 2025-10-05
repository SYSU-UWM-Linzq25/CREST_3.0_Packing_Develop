function [NSCE,tElapse]=Simulate(this,coreNo,x0,keywords)
%perform an entire simulation
% nModelVar is the new model parameter-set
    %in case the model parameters are updated by a
    %calibration process
%             tRunoff=0;% uncomment for speed test
%             tWaterBudget=0;% uncomment for speed test
%             tRouting=0;% uncomment for speed test
%             tRes=0;% uncomment for speed test
%             bCalib=false;
t1=cputime;% uncomment for speed test
if nargin==4
    mode='calib';
else
    mode='simu';
end

%             t2=cputime;% uncomment for speed test
%             tState=t2-t1;% uncomment for speed test
%             t1=cputime;% uncomment for speed test
if strcmpi(mode,'calib')
%                 bCalib=true;
    this.ModelParInit(coreNo,x0,keywords);
else
    this.ModelParInit(coreNo);
end
%             t2=cputime;% uncomment for speed test
%             tInit=t2-t1;% uncomment for speed test
%             t1=cputime;% uncomment for speed test
this.stateVar.preset();
if this.globalVar.numOfLoaded>0
    this.forcingVar.reset(mode,true);
    this.stateVar.LoadModelStates([this.globalVar.statePath,...
                datestr(this.forcingVar.dateCur,this.globalVar.timeFormat),'.mat']);
    this.forcingVar.MoveNext(mode);  
else
    this.forcingVar.reset(mode,false);
end
this.presetMedium();
this.stateVar.reset(this.soilSurf.nLayers);    
%             t2=cputime;% uncomment for speed test
%             tForce=t2-t1;% uncomment for speed test

%             dt=0;
bEnd=false;
timeOfStep=1;
t1=cputime;
while(~bEnd)
    if ~strcmpi(mode,'calib')
        disp(datestr(this.forcingVar.dateCur,'yyyy/mm/dd:HH:MM'))
    end
    % Convert unite of Rain and PET from mm/dt to mm
    % adjust rainfall
%                 t1=cputime;% uncomment for speed test
    this.GetForcing();
    
%                 t2=cputime;% uncomment for speed test
%                 tForce=tForce+t2-t1;% uncomment for speed test
    % compute water balance
    % uncomment for speed test
%                 t1=cputime;% uncomment for speed test
    this.LandSurfProc(coreNo);
%                 t2=cputime;% uncomment for speed test
%                 tRunoff=tRunoff+t2-t1;% uncomment for speed test
%                 t1=cputime;% uncomment for speed test
    if this.globalVar.doRouting
        this.WaterBudgetUpdate();
    end
%                 t2=cputime;% uncomment for speed test
%                 tWaterBudget=tWaterBudget+t2-t1;
%                 t1=cputime;% uncomment for speed test
    this.StateVarUpdate();
    
%                 t2=cputime;% uncomment for speed test
%                 tState=tState+t2-t1;% uncomment for speed test
    % route
%                 t1=cputime;% uncomment for speed test
    if this.globalVar.doRouting
        this.DownstreamRoute();
    end
%                 t2=cputime;% uncomment for speed test
%                 tRouting=tRouting+t2-t1;% uncomment for speed test
    % calculate the state variables for output or calibration
    % purpose
%                 t1=cputime;% uncomment for speed test
    this.stateVar.CalculateOutletData(timeOfStep,strcmpi(mode,'calib'),this.basicVar.masks); 
    this.stateVar.OutputVar(this.forcingVar.dateCur,...
        this.globalVar.output_Rain,this.globalVar.output_EPot,this.globalVar.output_EAct,...
        this.globalVar.output_SM,this.globalVar.output_W,...
        this.globalVar.output_runoff,...
        this.globalVar.output_ExcS,this.globalVar.output_ExcI,...
        this.globalVar.output_RS,this.globalVar.output_RI);
%                 t2=cputime;% uncomment for speed test
%                 tRes=tRes+t2-t1;% uncomment for speed test
%                 t1=cputime;% uncomment for speed test
    %% save model state variables
    if ~strcmpi(mode,'calib')
        if ismember(this.forcingVar.dateCur,this.globalVar.saveDates)
            dateToSave=datestr(this.forcingVar.dateCur+this.globalVar.saveOffset,this.globalVar.saveDateFormat);
            this.stateVar.SaveModelStates([this.globalVar.statePath,dateToSave,'.mat'],...
                this.modelPar.WM);
        end
    end
    
    %% move to the next time step
    timeOfStep=timeOfStep+1;
    bEnd=~this.forcingVar.MoveNext(mode);
    if bEnd && this.globalVar.numOfLoaded>0
        bEnd=this.forcingVar.reset(mode,true);
        if bEnd
            continue;
        end
        fileLoad=[this.globalVar.statePath,...
                datestr(this.forcingVar.dateCur,this.globalVar.timeFormat),'.mat'];
        this.stateVar.LoadModelStates(fileLoad);
        this.stateVar.reset(this.modelPar.WM);
        this.forcingVar.MoveNext(mode);
    end
    %% cell2cell evaulate land surface part
    this.evalLandProcVar(mode,bEnd,coreNo);
%                 t2=cputime;% uncomment for speed test
%                 tForce=tForce+t2-t1;% uncomment for speed test
%                 dt=dt+t2-t1;
end
t2=cputime;
tElapse=t2-t1;
if ~strcmpi(mode,'calib')
    disp(['total simulation time: ' num2str(tElapse) 'seconds']);
    if this.globalVar.doRouting
        [NSCE,Bias,CC]=this.stateVar.GetSingleObjNSCE();
        disp(strcat('NSCE=',num2str(NSCE)))
        disp(strcat('Bias=',num2str(Bias)))
        disp(strcat('CC=  ',num2str(CC)));
    else
        disp (['NSCE=' num2str(mean(this.stateVar.hydroSites.NSCE{1}))]);
        disp (['Bias=' num2str(mean(abs(this.stateVar.hydroSites.Bias{1})))]);
        disp (['total not converged cells by times; ' num2str(this.numOfNotConv)]);
        disp (['total cells by times where/where T exceeds limits; ' num2str(this.numOfImpossibleT)]);
        NSCE=NaN;
    end
else %calibration mode
    if this.globalVar.doRouting
        NSCE=this.stateVar.GetSingleObjNSCE();
    else
        NSCE=NaN;
    end
end
end