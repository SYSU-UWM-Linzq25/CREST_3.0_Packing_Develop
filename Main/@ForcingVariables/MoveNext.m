function [res,coarseUpdated]=MoveNext(this,mode,taskType,core,nCores)
coarseUpdated=false;
global SECONDS_PER_DAY
if round(this.dateCur*SECONDS_PER_DAY)<round(this.dateEnd(this.iPeriod)*SECONDS_PER_DAY)
    res=true;
else
    res=false;
%     return;
end
this.dateCur=ForcingVariables.addDatenum(this.dateCur,this.timeStep);
if strcmpi(taskType,'Routing') ||strcmpi(taskType,'Mosaic') || strcmpi(taskType,'DeepHydro_regrid')
    moveOnly=true;
else
    moveOnly=false;
end
if (~moveOnly) && res
    this.ReadIntForcing(mode,taskType,core,nCores);
end
if ~isempty(this.dateStartCoarse)
    dateCurCoarseNex=ForcingVariables.addDatenum(this.dateCurCoarse,this.timeStepCoarse);
    if abs(this.dateCur-dateCurCoarseNex)<abs(this.dateCur-this.dateCurCoarse)% the difference of current date time and coarse current datetime is smaller than that of current and last
        this.dateLastCoarse=this.dateCurCoarse;
        this.dateCurCoarse=dateCurCoarseNex;
        coarseUpdated=true;
        this.nAgger=1;
        disp('new date, start to aggregate')
    else
        this.nAgger=this.nAgger+1;
    end
end
end