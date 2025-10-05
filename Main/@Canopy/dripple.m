function dripple(this,dt,Tair,LAI,vaporFluxSub,vaporFluxEvapCanopy,...%vapor fluxes in (mm)
          energyPhaseChange,soilSurf)
%% computes and redistribute the intercepted ice and water after the energy balance is achieved
%% input 
% dt: (s) time step
if isempty(LAI)
    LAI=[];
    Tair=[];
    vaporFluxSub=[];
    vaporFluxEvapCanopy=[];
end
global RHO_W m2mm Lf SMALL
this.intSnow=this.intSnow+vaporFluxSub*dt;
vapor=max(-this.W,vaporFluxEvapCanopy*dt);
this.W=this.W+vapor;
this.W(abs(this.W)<SMALL)=0;
vaporRest=vaporFluxEvapCanopy*dt-vapor;
vaporRest(abs(vaporRest)<SMALL)=0;
if ~isempty(vaporRest)
    soilSurf.WThru(soilSurf.isOverstory)=soilSurf.WThru(soilSurf.isOverstory)+vaporRest;
end
% depth change in intercepted snow and rain(mm)
% depth>0 indicates water is refrozen -> the depth of snow SWE increases
% and the depth of rain SWE decrease
% vise esa.
dDepth=energyPhaseChange/Lf/RHO_W*m2mm*dt;
% subtract the mass that transfer to the other state in the beginning
isMelting=dDepth<0;
this.intSnow(isMelting)=this.intSnow(isMelting)+dDepth(isMelting);
this.W(~isMelting)=this.W(~isMelting)-dDepth(~isMelting);
% let the transferred mass go through an interception process as rainfall/snowfall
snowfall=zeros(this.nCells,1);
snowfall(~isMelting)=dDepth(~isMelting);
% snowfall(isMelting)=0;
rainfall=zeros(this.nCells,1);
rainfall(isMelting)=-dDepth(isMelting);
% rainfall(~isMelting)=0;
this.intercept(false,true,this.TSurf,LAI,snowfall,rainfall);
end