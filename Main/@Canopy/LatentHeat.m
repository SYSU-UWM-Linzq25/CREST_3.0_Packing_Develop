function [AET,actEvapCanopy,actEvapGrnd,actTranspir,vaporFluxSub,latentHeat,PET]=...
          LatentHeat(feedback,dt,nCells,hasSnow,...
             RaC,TfoliageTemp,eActAir,VPD,...
             rainfall,Tair,LAI,elevation,airDens,press,...
             netShortOver,netRadOver,...
             WmCan,WOrgCan,...
             root,Wcr, Wwp,rarc,r0c,RGL,...
             WSoil,iceSoil,SS0,intSnow,W)
%% Algorithm Description
% If there is intercepted snow, no transpiration but evaporation and sublimation of the interception happens.
% Otherwise evaportranspiration is going on
%% output
% AET (-mm/s): actual total evapotraspiration of liquid water
% vaporFluxSub (-mm/s): vapor flux due to sublimation of ice
% actEvapCanopy (-mm/s): evaporation from intercepted rain
% actTranspir (-mm/s): evaporated vapor due to transpiration
% latentHeat -W/(m^2)/s: total latent heat by AET and sublimation
%% input
% $$T_{foliageTemp}(^oC)$ : temporary solution of emperature of the canopy material
%
% dt (s): time interval, $$\Delta t$
%
% elevation (m): DEM
%
% netShortOver (W/m^2) : net shortwave radiation of the canopy layer(incoming-reflected)
%
% airDens $$(kgm^{-3}): \rho_{a}$, air density
%
% press (kPa): atmosphere pressure, $$ P_{a}$ 
%
% VPD (kPa): vapor pressure deficit, $$\delta e$
%
% eActAir (kPa): atmospheric vapor pressure (kPa), according to, it varies with height, $$e_{a}$ 

%
% netRadOver (W/m^2):net radiation imposed upon the canopy layer
%
% netShortOver (W/m^2):net short wave radiation imposed upon the canopy layer
%
% grndFlux (-W/m^2): ground flux caused by the temperature difference between the
    % bottom an dsurface of the surface soil layer. For snowpack covered cells,
    % the vaue should be zero since snow pack is a good insulator
global m2mm RHO_W Lv0 Lv1
nLayers=size(WSoil,2);
vaporFluxSub=zeros(nCells,1);
AET=zeros(nCells,1);
actEvapCanopy=zeros(nCells,1);
actEvapGrnd=zeros(nCells,1);
actTranspir=zeros(nCells,nLayers);
latentHeat=zeros(nCells,1);
PET=zeros(nCells,1);
%% snow intercepted cells
if any(hasSnow)
    [vaporFluxEvapSnow,vaporFluxSub(hasSnow),latentHeat(hasSnow),PET(hasSnow)]=latentHeatFrmSnow(dt,...
        airDens(hasSnow),press(hasSnow),VPD(hasSnow),eActAir(hasSnow),...
        RaC(hasSnow),TfoliageTemp(hasSnow),intSnow(hasSnow),W(hasSnow));
end
%% non snow intercepted cells
% evapotranspiration
% the surface water is not accounted in the evapotranspiration process when there is snow pack on the ground
if any(~hasSnow)
%     [AET(~hasSnow),actEvapCanopy(~hasSnow),~,actTranspir(~hasSnow,:)] =...
%     canopy_ET(feedback, dt, elevation(~hasSnow), WmCan(~hasSnow),WOrgCan(~hasSnow),... 
%             SS0(~hasSnow),root(~hasSnow,:),Wcr(~hasSnow,:), Wwp(~hasSnow,:), WSoil(~hasSnow,:),iceSoil(~hasSnow,:),...
%             airDens(~hasSnow),press(~hasSnow),rainfall(~hasSnow),Tair(~hasSnow),...
%             TfoliageTemp(~hasSnow),eActAir(~hasSnow),VPD(~hasSnow), LAI(~hasSnow),netRadOver(~hasSnow), ...
%             netShortOver(~hasSnow),RaC(~hasSnow),rarc(~hasSnow),...
%             r0c(~hasSnow),RGL(~hasSnow));

    [AET(~hasSnow),actEvapCanopy(~hasSnow),actEvapGrnd(~hasSnow),actTranspir(~hasSnow,:),PET(~hasSnow)]=...
        canopy_ET2(feedback,dt,elevation(~hasSnow),WmCan(~hasSnow),WOrgCan(~hasSnow),...
        SS0(~hasSnow),root(~hasSnow,:),Wcr(~hasSnow,:), Wwp(~hasSnow,:), WSoil(~hasSnow,:),iceSoil(~hasSnow,:),...% state variables
        rainfall(~hasSnow),Tair(~hasSnow),...
        VPD(~hasSnow),LAI(~hasSnow),netRadOver(~hasSnow),netShortOver(~hasSnow),RaC(~hasSnow),...% forcing
        rarc(~hasSnow),r0c(~hasSnow),RGL(~hasSnow));
        PET(~hasSnow)=-PET(~hasSnow)/dt;
    AET(~hasSnow)=-AET(~hasSnow)/dt;
    % programming bug, fixed on Sept. 29, 2015
    actEvapGrnd(~hasSnow)=-actEvapGrnd(~hasSnow)/dt;
%     Le=zeros(this.nCells,1);
    %% CREST corrected, Le should be calculated using the temperature of the medium rather than the above air
    %
    % Le (J/g): latent heats, $$L_{water}$
    Le= Lv0 + Lv1 * TfoliageTemp(~hasSnow);
    % latent heat for evapotranspiration in cells without intercepted snow
    latentHeat(~hasSnow)= Le.*AET(~hasSnow)/m2mm * RHO_W;
end
%mm to -mm/s,%CREST corrected, VIC commit a sign error here
actEvapCanopy=-actEvapCanopy/dt;
if any(hasSnow)
    actEvapCanopy(hasSnow)=vaporFluxEvapSnow;
    AET(hasSnow)=vaporFluxEvapSnow+vaporFluxSub(hasSnow);
end
actTranspir=-actTranspir/dt;
end