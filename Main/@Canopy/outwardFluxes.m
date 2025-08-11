function [RaC,sensibleHeat,longOverOut,netShort,sensibleHeatAtm]=...
    outwardFluxes(nCells,hasSnow,roughness,adj_displacement,adj_ref_height,...
                  UAdj,RAero,albedo,...
                  TfoliageTemp,TcanopyTemp,airDens,Tair,shortOverIn,shortReflected,...
                  short_atten)
%% output
% longOverOut (W/m^2):upward long wave radiation from the canopy
% sensibleHeat (-W/m^2); sensible heat exchange between foliage and surrounding air, from canopy to air
% sensibleHeatAtm (-W/m^2) sensible heat exchange bewteen atmosphere and surrounding air, from surrounding air to atmosphere
% RaC: corrected aerodynamic resistence of heat
%% input
%
% $$T_{foliageTemp}(^oC)$ : temporary solution of emperature of the canopy material
%
% $$T_{canopyTemp} (^oC)$ : temporary solution of the temperature of the surrounding air of canopy
%
% $$T_{air} (^oC)$ atmospheric temperature
%
% airDens $$(kgm^{-3}): \rho_{a}$, air density
%
% shortOverIn $$(Wm^{-2})$: incoming of short wave radiation after reflection by the canopy
%
% shortReflected $$(Wm^{-2})$: reflected short wave radiation by the understory surface (snow pack or soil)
%
% longOverIn $$(Wm^{-2})$: downward long wave radiation from the atmosphere
%
% longUnderOut $$(Wm^{-2})$: upward long wave radiation from the understory
if nCells==0
    RaC=[];
    sensibleHeat=[];
    longOverOut=[];
    netShort=[];
    sensibleHeatAtm=[];
    return;
end
global KELVIN STEFAN HUGE_RESIST CP_PM NEW_SNOW_ALB
TFoliageInK = TfoliageTemp + KELVIN;
%%% Stefam-Boltzmann law for blackbody
% total energy radiated per unit surface area of a black body across all wavelengths per unit time
%
% $j^{\star} = \sigma T^{4}$
longOverOut = STEFAN * TFoliageInK.^4;
% if there is no snow interception, zero temperature difference causes no correction
[correction,noWind]=Canopy.StabilityCorrection(nCells,UAdj,roughness,adj_displacement,adj_ref_height,...
                       TfoliageTemp,TcanopyTemp);
correctionAC=Canopy.StabilityCorrection(nCells,UAdj,roughness,adj_displacement,adj_ref_height,...
                       TcanopyTemp,Tair);
RaC=RAero./correction;
% RaC(hasWind)=this.RAero(hasWind)./this.StabilityCorrection(TfoliageTemp(hasWind),TcanopyTemp(hasWind),this.UAdj(hasWind));
RaC(noWind)=HUGE_RESIST;
sensibleHeat=zeros(nCells,1);
sensibleHeat(hasSnow) = CP_PM*airDens(hasSnow) .* (TcanopyTemp(hasSnow) - TfoliageTemp(hasSnow)) ./ RaC(hasSnow);
sensibleHeat(~hasSnow)=0;
sensibleHeatAtm=zeros(nCells,1);
%% Ra corrected by the temperature difference between the Tcanopy and Tair(bug in VIC, corrected in CREST)
RaCAC=RAero./correctionAC;
RaCAC(noWind)=HUGE_RESIST;
sensibleHeatAtm(hasSnow) = CP_PM *airDens(hasSnow).* (Tair(hasSnow) - TcanopyTemp(hasSnow)) ./  RaCAC(hasSnow);
% sensibleHeatAtm(~this.hasSnow)=0;
%% net short wave radiation imposed on the canopy layer
%CREST (added the shortwave radiation reflected by the understory and attenuated by the canopy)
ALBEDO=NEW_SNOW_ALB*hasSnow+albedo.*(~hasSnow);
netShort = shortOverIn.*(1-ALBEDO) +shortReflected.*(1-short_atten);%CREST corrected 
end