function preset(this,stateVar,forcingVar)
global m2mm
%% reset all state variables before a simulation 
% the simlulate function is responsible to call this function every time
%% water states
for iL=1:this.nLayers
%     this.W(:,iL)=stateVar.pW0(stateVar.basinMask)/100.*this.Wm(:,iL);
    this.W(:,iL)=stateVar.pW0(stateVar.basinMask)/100*this.depths(iL)*m2mm;
    overSat=this.W(:,iL)>this.Wm(:,iL);
    this.W(overSat,iL)=this.Wm(overSat,iL);
%     if any(this.W(:,iL)>this.Wm(:,iL))
%         error('Initial soil moisture value larger than the saturated soil moisture.')
%     end
end
this.WVeg(:)=0;
this.ice(:)=0;
this.Wperc(:,:)=0;
this.WmVeg(:)=0;
this.WMM=this.Wm(:,1).*(1.0+this.b_infilt);
%% thermal states
this.T2=stateVar.Tdamp(stateVar.basinMask);
this.TSurf=forcingVar.Tair(forcingVar.basinMask);
this.T1=this.T2+(this.TSurf-this.T2)*0.2;
end