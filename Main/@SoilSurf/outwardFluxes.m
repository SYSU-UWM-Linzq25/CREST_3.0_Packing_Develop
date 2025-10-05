function [RaC,sensibleHeat,longUpward,shortReflected,netShort,grndFlux,grndFlux1,netGrndFlux,T1Temp]=...
    outwardFluxes(nCells,hasSnow,roughness,adj_displacement,adj_ref_height,...
               UAdj,RAero,albedo,...
               TSurfTemp,Tair,airDens,...
               shortBareIn,dt,optSoilThermal,...
               D1,D2,dp,kappa,Cs,T1,T2)
%% Algorithm Description
% calculate the outward fluxes produced in the current media that
% are needed in the energy balances in the current or other medium.
% This function must be called prior to latent heat because latent heat
% depends on the net radiation
% The input of this function are simply temperatures and other physical
% properties of the layer
% All grids within the basin are calculated in this function
%% output
% grndflux: ground flux to the upper layer, note that in VIC, the
    % netGrndflux, flux0_air-flux1-0 is used for ET, which is
    % incorrect
% longUpward upward longwave radiation by the soil layer
% sensibleHeat: sensible heat flux due to the temperature difference
% between the upper boundary
%% input
% dt
% TSoilTemp
% TAirTemp
%% main routine
global HUGE_RESIST CP_PM KELVIN STEFAN
%% correction of aerodynamic resistence
% the aerodynamic resistence are used for ET/sensible heat thus is calculated at the
% boundary between air and the ground. With snow pack, snow pack's
% aerodynamic resistence and adjusted windspeed is used
% Note that in cells with a overstory, understory aerodynamic variables are
% used because only the sensible heat is calculated while the latent heat
% is calculated by methods in the Canopy class
RaC=nan(nCells,1);
[correction, noWind]=SoilSurf.StabilityCorrection(nCells,UAdj,...
    roughness,adj_displacement,adj_ref_height,TSurfTemp,Tair);
RaC(~noWind)=RAero(~noWind)./correction(~noWind);
RaC(noWind)=HUGE_RESIST;
RaC(hasSnow)=NaN;
%% Sensible Heat
% cells without a snow pack has the sensible heat
sensibleHeat=zeros(nCells,1);
sensibleHeat(~hasSnow) = airDens(~hasSnow)* CP_PM.* (Tair(~hasSnow) - TSurfTemp(~hasSnow)) ./ RaC(~hasSnow);
% the tempearature profile is assumed continuously between all solid medium
% including the snowpack and surfalce soil. Therefore, the sensible heat is
% zero between this layer
% sensibleHeat(this.hasSnow)=0;
%% Ground flux (all cells) 

[T1Temp,grndFlux,grndFlux1,netGrndFlux]=SoilSurf.nextT1(D1,D2,dp,kappa,Cs,TSurfTemp,T1,T2,dt,optSoilThermal);
%% upward long wave
% cells without a snow pack has the outgoing longwave radiation
TSurfTempK=TSurfTemp(~hasSnow)+KELVIN;
longUpward=zeros(nCells,1);
longUpward(~hasSnow) = STEFAN * TSurfTempK.^4;
% longUpward(this.hasSnow)=0;
%% reflected short wave from the soil surface
shortReflected=zeros(nCells,1);
shortReflected(~hasSnow)=shortBareIn(~hasSnow).*albedo(~hasSnow);
%% net short wave imposed on the soil surface layer
netShort=shortBareIn;
netShort(~hasSnow)=shortBareIn(~hasSnow).*(1-albedo(~hasSnow));
end