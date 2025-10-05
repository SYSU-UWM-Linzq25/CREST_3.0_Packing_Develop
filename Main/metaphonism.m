function metaphonism(this,dt,energyPhaseChange,deltaCCSurf,dCCPack,meltedPackIce,vaporMassEvap,vaporMassSub)
%% updates the existing snow and water in the snow pack using the melted, refrozen, evaporated and sublimated depth
% and calculate the density, albedo and depth
% remove evaporated surface water and sublimated swq
%% input
% vaporMassEvap(-mm/s)
% vaporMassSub(-mm/s)
% grndFluxToPack: ground heat flux from soil due to the temperature
% gradient of soil surface and deep soil that is used to consume cold
% content or even melt pack layer ice
global RHO_W Lf m2mm
%% accounting evaporation due to the latent heat
% only surface water can be evaporated
this.W(this.hasSnow)=this.W(this.hasSnow)+vaporMassEvap*dt;
this.swqTotal(this.hasSnow)=this.swqTotal(this.hasSnow)+vaporMassEvap*dt;
%% acounting sublimation due to the latent heat 
this.swqTotal(this.hasSnow)=this.swqTotal(this.hasSnow)+vaporMassSub*dt;
%% Melting and Refreezing
% iceSurf(this.hasSnow)=this.swqPack(this.hasSnow)+vaporMassSub*dt;
% note that dDepth has the size of all grids
dDepth(this.hasSnow)=energyPhaseChange/Lf/RHO_W*m2mm*dt;
% subtract the mass that transfer to the other state in the beginning
isMelting=dDepth<0;
isRefreezing=dDepth>0;
% cells has no snow, or no phase change will not be calculated
% dSWQPack=max(-this.swqPack(isMelting),dDepth(isMelting));
%% Melting
% all melted water are added to surface first
this.W(isMelting)=this.W(isMelting)-dDepth(isMelting);
% the reduce of ice due to melting starts from the pack layer
% this.swqPack(isMelting)=this.swqPack(isMelting)+dSWQPack;
% dSWQSurf=dDepth(isMelting)-dSWQPack;
% if the pack ice is exhausted, the surface ice can be reduced 
% this.swqSurf(isMelting)=this.swqSurf(isMelting)+dSWQSurf;
% add the melted water into the surface layer
% if the pack layer is exhausted, all pack water is also added to the
% surface
% this.W(isMelting)=this.W(isMelting)-dDepth(isMelting)+(dSWQSurf<0).*(+this.WPack(isMelting));
%% refreezing
% the refrozen of water only happens on the surface layer
this.W(isRefreezing)=this.W(isRefreezing)-dDepth(isRefreezing);
% this.swqSurf(isRefreezing)=this.swqSurf+dDepth(~isMelting);
%% cold content
this.CCSurf(this.hasSnow)=this.CCSurf(this.hasSnow)+deltaCCSurf*dt;
%% heat exchange between the pack layer and soil layer
this.CCPack(this.hasSnow)=this.CCPack(this.hasSnow)+dCCPack;
this.W(this.hasSnow)=this.W(this.hasSnow)+meltedPackIce;
%% update this.hasSnow
[ice,~,icePack]=getIce(this);
this.hasSnow=ice>0;
packVanishes=icePack==0;
this.W(packVanishes)=this.W(packVanishes)+this.WPack(packVanishes);
this.WPack(packVanishes)=0;
end