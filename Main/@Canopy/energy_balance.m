function [error,energyPhaseChange]=...
    energy_balance(nCells,hasSnow,...
              TfoliageTemp,dt,sensibleHeat,latentHeat,netRad,vaporFluxEvap,vaporFluxSub,...
              CH_positive,CH_negative,...
              intSnow,W,TSurf,TW)
%% Algorithm Description
% calculate the energy balance of the foliage layer where there is intercepted snow.
% and the energy budget of foliage where there is no intercepted snow.
%
% $$Int_{snow} +Pack_{snow}>0$
%
% Energy balance is solved WITHIN the FOLIAGE and the boundary of this medium is ONLY the surrounding air of the canopy.
%
% $$CASE1:  \, and \, (Int_{rain}>0\,or\,Int_{snow})>0$
%
% $$ T_{foliage} \not= T_{canopy}, T_{foliage} \not= T_{air}, T_{canopy} \not= T_{air},T_{foliage}<=0$$
%
% The energy budget MUST be balanced within the foliage medium by adjust $$T_{foliage}$.
%
% Only the over portion of radiation is used as input in this circumstance.
%
% if there is intercepted snow, no evapotranspiration but sublimation happens.
%
% $$CASE 2:Int_{snow}=0,Int_{rain}=0$
%
% $$ T_{canopyTemp}=T_{air}=T_{foliage} $$
%
% There is no energy balance,refreezing or melting process within this medium.
%
% The foliage and snowpack will be treated as one medium to solve the energy balance. 
%
% The total radiation is imposed on the foliage medium first to estimate the evapotranspiration. 
%
% Then the "error" in the foliage medium will be input to balance of the budget of the snowpack layer.
%% output arguments
% error (W/m^2): total energy balance. error=0 indecates the foliage (canopy) layer is balanced
% energyPhaseChange(J/m^2/s): released energy due to refreezing(+)/melting(-)
%% input arguments
% $$T_{foliageTemp}(^oC)$ : temporary solution of emperature of the canopy material
%
% dt (s): time interval, $$\Delta t$
%
% $$ T_{air} (^oC)$ air temperature
%
% vaporFluxEvap (-mm/s):vapor flux due to evaporation
%
% vaporFluxSub (-mm/s): vapor flux due to sublimation
%
if nCells==0
    error=[];
    energyPhaseChange=[];
    return;
end
energyPhaseChange=zeros(nCells,1);
%% advected energy flux
% advectedEnergy = 4186.8 * Tcanopy.* rainfall/m2mm/dt;%VIC(wrong, rainfall in VIC is the total rainfall, 
% Absurd error in VIC, 4186 is for depth in mm, 4186e3 should be used)
% Another ignorance in VIC, the advected energy by snow fall should also be added into the advected Energy
% the falls reach the temperature of the last time step, this.TSurf here
% then change to the temperature of the current time step with the interception.
% rainfall(mm) : newly intercepted rainfall rather than the total rainfall in VIC
% snowfall(mm) : newly intercepted snow fall (ignored in VIC)
% snowfall=intSnow-intSnowOrg;
% rainfall=W-WOrg;
% cold content of the new snow is taken into account in the interception process
% therefore, the advected energy only contains the heat in rainfall
advectedEnergy=MixedHeatChange(TfoliageTemp,TW,W,CH_positive,CH_negative)/dt;
% advectedEnergy=MixedHeatChange(TSurf,Tair,rainfall+snowfall,CH_positive,CH_negative)/dt;
%% heat storage change in the intercepted snow %CREST only
deltaCC=MixedHeatChange(TfoliageTemp,TSurf,intSnow,CH_positive,CH_negative)/dt;
%% energy budget
error = sensibleHeat+netRad-advectedEnergy+latentHeat-deltaCC;
%% energy due to phase change
% overstory cells without intercepted snow do/can not balance the
% budget by refreezing or melting process
energyPhaseChange(hasSnow)=EnergyByPhaseChange(dt,error(hasSnow),...
    TfoliageTemp(hasSnow),W(hasSnow),intSnow(hasSnow),...
    vaporFluxSub(hasSnow),vaporFluxEvap(hasSnow));
energyPhaseChange(~hasSnow)=0;
error(hasSnow)=error(hasSnow)+energyPhaseChange(hasSnow);
end