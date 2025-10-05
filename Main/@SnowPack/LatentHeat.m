function [vaporMassEvap,vaporMassSub,latentHeat,vaporMassFlux]=LatentHeat(...
    dt,nCells,hasSnow,RaC,TSnowSurfTemp,eActAir,vpd,airDens,press,...
    iceSurf,icePack,W)
%% output
% vaporMassEvap (-mm/s): evaporated water depth
% vaporMassSub (-mm/s): sublimated depth of snow water equivalence
% latentHeat -W/(m^2)/s: latent heat is negative if evaporation or sublimation happens
% vaporMassFlux (-mm/s): potential ET for sublimation and evaporation from snow pack
%% update history
% updated by Shen, Xinyi in April, 2016
% an assumption is imposed: Sublimation & Evaporation is
% assumed only to occur at the surface layer of the snow pack
% updated by Shen, Xinyi in Jan. 14, 2019
vaporMassEvap=zeros(nCells,1);
vaporMassSub=zeros(nCells,1);
vaporMassFlux=zeros(nCells,1);
latentHeat=zeros(nCells,1);
if any(hasSnow)
    [vaporMassEvap(hasSnow),vaporMassSub(hasSnow),latentHeat(hasSnow),vaporMassFlux(hasSnow)]=latentHeatFrmSnow(dt,...
        airDens(hasSnow),press(hasSnow),vpd(hasSnow),eActAir(hasSnow),RaC(hasSnow),...
        TSnowSurfTemp(hasSnow),iceSurf(hasSnow)...
        ...+icePack(hasSnow)
        ,W(hasSnow));
end
end