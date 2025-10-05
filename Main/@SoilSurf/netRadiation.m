function [netBareRad,netBareRadET]=netRadiation(nCells,hasSnow,isOverstory,isBare,netShortBare,longBareIn,longBareOut,grndFlux,netGrndflux)
%% output
% netBareRad (W/m^2): net radiation within the surface soil layer (layer 0)
% netBareRadET (W/m^2): net radiation upon the soil surfac
%% input
% longBareIn (W/m^2): downward long wave radiation to the baresoil
% longUnderOut (W/m^2): upward long wave radiation by the surface soil
% grndFlux (-W/m^2):ground flux from the surface soil to the upper layer
% grndFlux1 (W/m^2)): ground flux from the deep soil layer to the surface soil layer
%% net long wave imposed on the soil surface layer
netLongBare=zeros(nCells,1);
netLongBare(~hasSnow)=longBareIn(~hasSnow)-longBareOut(~hasSnow);
%% net radiation above the soil surface (for ET)
netBareRad=netShortBare+netLongBare;
netBareRadET=zeros(nCells,1);
% if the surface is covered by snow, there is no ET at all for low
% vegetation or bare soil
% if it is covered with canopy, the ET is computed within the canopy layer
hasSnowOrOverstory=hasSnow|isOverstory;
netBareRadET(~hasSnowOrOverstory)=netBareRad(~hasSnowOrOverstory)-grndFlux(~hasSnowOrOverstory);
%% net radiation within the soil surface layer (for energy balance)
netBareRad = netBareRad + netGrndflux;% + dHeat VIC error: dHeat is not radiated flux
%% for cells without snow pack and is not bare and without an overstory
% the ground flux from soil to the upper vegetation is added back to
% participate the energy balance because the upper vegetation is also
% included in the energy balance of the soil surface
% for cells has a canopy layer without snowpack, the flux is added to the
% canopy layer's budget or balance so not be added here. 
% If it is a budget it will eventually be added back from the error of the
% canopy. If it must be balanced in the canopy, this energy will be
% considered in the canopy layer.
surfaceFluxAbsorbed=~(hasSnow|isBare|isOverstory);
netBareRad(surfaceFluxAbsorbed)=netBareRad(surfaceFluxAbsorbed)-grndFlux(surfaceFluxAbsorbed);
end