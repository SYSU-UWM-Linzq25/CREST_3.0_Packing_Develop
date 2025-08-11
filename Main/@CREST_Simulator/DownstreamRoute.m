function DownstreamRoute(this)
%% update total runoff within one grid
this.runoff=(this.RS+this.RI)/this.globalVar.timeStepInMRoute.*this.gridArea/3.6*this.rTimeUnit;%m^3/s
this.stateVar.runoff(this.maskRoute)=this.runoff;
% sum up the streamflow passed by
%% comment the section below to switch to CREST 2.0, QDLRR
if ~isempty(this.RSPassedIndex)
    dRunoffS= accumarray(this.RSPassedIndex,...
        this.stateVar.RS(this.RSStartedIndex).*this.basicVar.gridArea(this.RSStartedIndex)/(this.globalVar.timeStepInMRoute*3.6/this.rTimeUnit),[],[],[],false);
    dRunoffS=dRunoffS(this.uRSPassedIndex);
    this.stateVar.runoff(this.uRSPassedIndex)=this.stateVar.runoff(this.uRSPassedIndex)+dRunoffS;
end
if ~isempty(this.RIPassedIndex)
    dRunoffI=accumarray(this.RIPassedIndex,...
        this.stateVar.RI(this.RIStartedIndex).*this.basicVar.gridArea(this.RIStartedIndex)/(this.globalVar.timeStepInMRoute*3.6/this.rTimeUnit),[],[],[],false);
    dRunoffI=dRunoffI(this.uRIPassedIndex);
    this.stateVar.runoff(this.uRIPassedIndex)=this.stateVar.runoff(this.uRIPassedIndex)+dRunoffI;
end
%end of the comment area
%% update water storage
if ~isempty(this.SIndexA)
    dSS0=accumarray(this.SIndexA,...
        this.RS(this.SIndexAValid).*this.SFracA.*this.SgridAreaA,[],[],[],false);
    dSS0=dSS0(this.uSIndexA);
    this.stateVar.SS0(this.uSIndexA)=this.stateVar.SS0(this.uSIndexA)+...
    dSS0./this.basicVar.gridArea(this.uSIndexA);
end
if ~isempty(this.SIndexB)
    dSS0=accumarray(this.SIndexB,...
        this.RS(this.SIndexBValid).*this.SFracB.*this.SgridAreaB,[],[],[],false);
    dSS0=dSS0(this.uSIndexB);
    this.stateVar.SS0(this.uSIndexB)=this.stateVar.SS0(this.uSIndexB)+...
        dSS0./this.basicVar.gridArea(this.uSIndexB);
end
if ~isempty(this.IIndexA)
    dSI0=accumarray(this.IIndexA,...
        this.RI(this.IIndexAValid).*this.IFracA.*this.IgridAreaA,[],[],[],false);
    dSI0=dSI0(this.uIIndexA);
    this.stateVar.SI0(this.uIIndexA)=this.stateVar.SI0(this.uIIndexA)+...
        dSI0./this.basicVar.gridArea(this.uIIndexA);
end
if ~isempty(this.IIndexB)
    dSI0=accumarray(this.IIndexB,...
        this.RI(this.IIndexBValid).*this.IFracB.*this.IgridAreaB,[],[],[],false);
    dSI0=dSI0(this.uIIndexB);
    this.stateVar.SI0(this.uIIndexB)=this.stateVar.SI0(this.uIIndexB)+...
        dSI0./this.basicVar.gridArea(this.uIIndexB);
end
end      