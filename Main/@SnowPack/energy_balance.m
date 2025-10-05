function [error,dCCSurf,dCCPack,refrozenIcePack,energyPhaseChange]=energy_balance(nCells,hasSnow,isOverstory,TSurfTemp,dt,...
                            netRad,TRain,rainfall,iceSurf,icePack,...
                            sensibleHeat,latentHeat,...
                            vaporMassEvap,vaporMassSub,...
                            groundFlux,errorCanopy,...
                            CH_positive,CH_negative,...
                            TSurf,W,WPack,CCPack)
%% Algorithm Description
% calculate the energy balance of the snowpack surface layer.
% only in the cells coverred with ice should a user call this function
% cells without snow cover has already been filtered out before entering
% this function
%% output
% error   (W/m^2)
% dCCSurf (W/m^2)
% dCCPack (W/m^2)
% refrozenIcePack(mm)
% energyPhaseChange (W/m^2)
%% input
% $$T_{Surf_temp}(^oC)$ : temporary solution of temperature of the canopy material
%
% dt (s): time interval, $$\Delta t$
%
% grndFluxReminderFrmSoil (W/m^2):This is a new term in CREST. The ground heat flux, if not exhausted by the cold content of the pack layer, must be added to the surface layer 
if nCells==0
    error=[];
    dCCSurf=[];
    dCCPack=[];
    refrozenIcePack=[];
    energyPhaseChange=[];
    return;
end
global RHO_W Lf m2mm
%% advected energy flux
% the advected energy by snow fall has already been accounted for in the compaction process
advectedEnergy=zeros(nCells,1);
advectedEnergy(hasSnow)=MixedHeatChange(TRain(hasSnow),TSurf(hasSnow),rainfall(hasSnow),CH_positive,CH_negative)/dt;
%% heat storage change
% swq and liquid water are both treated as "ice" here 
dCCSurf=zeros(nCells,1);
dCCSurf(hasSnow)=MixedHeatChange(TSurfTemp(hasSnow),TSurf(hasSnow),...
    iceSurf(hasSnow)+W(hasSnow),CH_positive,CH_negative)/dt;
%% ground flux
% if the pack layer exists, it is the sensible heat from the pack layer to
% the surface layer
% this term can be ignored in practice
% groundFlux= K0Snow * this.density(this.hasSnow).^2.*(TGrnd - this.TSurf(this.hasSnow))./ this.depth(this.hasSnow) / dt;
% otherwise, it is the heat flux from the surface soil to the pack surface
% groundFlux(this.depth(this.hasSnow)==0)=0;
% groundFlux=0;
%% CREST added isulator effects of the pack layer, i.e., accouting the soil flux to the pack then surface layer
% the heat exchange between the pack layer and the soil surface layer is
% described as
% if there is enough cold content in the pack layer, it will be consumed
% by the heat flux from soil. It can be exhausted and even the ice can be
% melted to neutralize this heat flux
% if all ice in the pack layer has been consumed, this portion of energy
% adds to the energy budget of the surface layer
% all the melted water by the ground flux is added to the surface layer
% as well
% if the flux is negative, theoretically some water must be refrozen in the
% pack layer, but this algorithm only adds cold content
% groundFlux(~this.hasSnow)=0;% this has been fullfilled before entering
% the functino
isPositiveFlux=groundFlux<0;% from soil to pack
isNegativeFlux=groundFlux>0;% from pack to soil
remPackIce=zeros(nCells,1);
refrozenIcePack=zeros(nCells,1);
energyPhaseChange=zeros(nCells,1);
% meltedPackIce=zeros(this.nCells,1);
%% cold content change in the pack layer due to soil flux
% soil flux is also consumed by the pack layer in the process
% case 1: if the soil flux is upward, it consumes the cold content of the pack
% layer and the rest of it is added to the energy balance of the surface
% layer because the melting process always happen after all CC of both
% layers is consumed up.
% case 2: if the soil flux is downward, it refreezes the pack water in the first
% place then increase the CC in the pack layer and won't penetrate the pack
% layer
%% case 1:
dCCPack=zeros(nCells,1);
% positive flux consumes the cold content of the pack first
dCCPack(isPositiveFlux)=min(-groundFlux(isPositiveFlux),-CCPack(isPositiveFlux)/dt);
    % the remaing positive flux after consuming the cc in the pack layer
groundFlux(isPositiveFlux)=groundFlux(isPositiveFlux)+dCCPack(isPositiveFlux);
    % the remaining ice after sublimation
%% case 2:
isIncreCC=icePack>0 & isNegativeFlux;
dCCPack(isIncreCC)=-groundFlux(isIncreCC);
refrozenIcePack(isIncreCC)=min(-dCCPack(isIncreCC)*dt/(Lf*RHO_W)*m2mm,WPack(isIncreCC));
dCCPack(isIncreCC)=dCCPack(isIncreCC)+refrozenIcePack(isIncreCC)/m2mm*Lf*RHO_W/dt;
remPackIce(isIncreCC)=icePack(isIncreCC)+refrozenIcePack(isIncreCC);
groundFlux(isIncreCC)=0;
% remaining CC in the pack layer
remCCPack=CCPack+dCCPack*dt;
%% energy budget in the surface layer
% note that the groundflux is not included in the netRad in the snow pack
% medium
error = netRad + sensibleHeat + latentHeat+advectedEnergy - groundFlux - dCCSurf;
% the energy budget of canopy without snow interception must be added to
% either the snowpack energy balance where there is snow pack or the soil surface where there is no snowpack 
if ~isempty(errorCanopy)
    error(isOverstory)=error(isOverstory)+errorCanopy.*hasSnow(isOverstory);
end
%% melting and refreezing
% the melting/refreezing process of the surface layer is symmetric to the
% pack layer, i.e., in the heating process, melting must happen after the CC of both layers are
% consumed up and the ice in both layers can be melted. Therefore, the CC in the pack layer is converted to virtual ice 
% But in the cooling process, the refrozen process only refreezes the liquid water in the source side (soil
% flux refrozen) and only the CC at the source side is increased.
energyPhaseChange(hasSnow)=EnergyByPhaseChange(dt,error(hasSnow),TSurfTemp(hasSnow),W(hasSnow),...
   iceSurf(hasSnow)+remPackIce(hasSnow)-remCCPack(hasSnow)/(Lf*RHO_W)*m2mm,vaporMassSub(hasSnow),vaporMassEvap(hasSnow));
error(hasSnow)=error(hasSnow)+energyPhaseChange(hasSnow);
%% advected energy must be accounted into the total CC change of the surface layer
% dCCSurf(hasSnow)=dCCSurf(hasSnow)-advectedEnergy(hasSnow)+MixedHeatChange(0,TSurfTemp(hasSnow),-vaporMassSub,CH_positive,CH_negative);
end