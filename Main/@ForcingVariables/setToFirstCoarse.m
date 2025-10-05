function setToFirstCoarse(this,dateStartOrg)
%% set dateCur and dateCurCoarse to the nearest matching position prior to dateStart

%% find the nearest coarse date
hit=false;
offset=0;
while ~hit
    date0=ForcingVariables.addDatenum(this.dateStart,-offset*this.timeStep/2);
    hit=IsAtACoarseTime(date0,this.dateStartCoarse,this.timeStepCoarse);
    offset=offset+1;
end
if date0<this.dateStartCoarse
    date0=this.dateStartCoarse;
end
this.dateStartCoarse=date0;
%% take the found coarse time step as center, find the earliest time step of this coarse one
dateCoarseCur=this.dateStartCoarse;
dateCoarseLast=ForcingVariables.addDatenum(dateCoarseCur,-this.timeStepCoarse);
changed=false;
% move the starting time nearest to the dateCurCoarse;
nOffset=round((this.dateStart-this.dateStartCoarse)/(this.timeStep));
date0=ForcingVariables.addDatenum(this.dateStart,-nOffset*this.timeStep);
while ~changed
    diff1=abs(date0-dateCoarseCur);
    diff2=abs(date0-dateCoarseLast);
    if diff1>diff2
        changed=true;
    else
        date0=ForcingVariables.addDatenum(date0,-this.timeStep);
    end
end
this.dateStart=ForcingVariables.addDatenum(date0,this.timeStep);
if dateStartOrg>this.dateCur
    this.dateStart=dateStartOrg;
end
if abs(this.dateStart-this.dateCurCoarse)-this.timeStepCoarse>1e-8
    error('Two time lines do not match. Check your global Control file')
end
this.dateCur=this.dateStart;
this.dateCurCoarse=this.dateStartCoarse;
this.dateLastCoarse=ForcingVariables.addDatenum(this.dateCurCoarse,-this.timeStepCoarse);
end
function hit=IsAtACoarseTime(date,dateStartCoarse,timeStepCoarse)
global SECONDS_PER_DAY
diffInSec=round(date*SECONDS_PER_DAY)-round(dateStartCoarse*SECONDS_PER_DAY);
timeStepCoarseInSec=round(timeStepCoarse*SECONDS_PER_DAY);
hit=mod(diffInSec,timeStepCoarseInSec)==0;
end