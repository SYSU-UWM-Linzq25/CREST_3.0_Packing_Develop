function WaterBudgetUpdate(this)
%% update history
%% update the water storage
% if multiple types exist for one cell, sum up all types here
this.SS0=this.stateVar.SS0(this.maskRoute)+this.stateVar.excS(this.maskRoute);
this.SI0=this.stateVar.SI0(this.maskRoute)+this.stateVar.excI(this.maskRoute);
%% compute the outcoming and incoming water from linear reservoirs
if ~this.globalVar.hasRiverInterflow
   this.stateVar.SS0(this.maskRoute)=this.SS0;
   this.stateVar.SI0(this.maskRoute)=this.SI0;
   this.stateVar.SS0(this.basicVar.stream)=this.stateVar.SS0(this.basicVar.stream)+this.stateVar.SI0(this.basicVar.stream);
   this.stateVar.SI0(this.basicVar.stream)=0;
   this.SS0=this.stateVar.SS0(this.maskRoute);
   this.SI0=this.stateVar.SI0(this.maskRoute);
end
this.RS=this.SS0.*this.KS;
this.SS0=this.SS0-this.RS;
this.RI=this.SI0.*this.KI;
this.SI0=this.SI0-this.RI;
end