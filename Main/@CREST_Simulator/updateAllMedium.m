function rainBare=updateAllMedium(this,Tfoliage,Tcanopy,TSnow,Tsoil,T1Soil,...
    vaporFluxSub_can,actEvap_can,actEvapGrnd_can,actTranspir_can,energyPhaseChange_can,...
    dCCSurf,dCCPack,refrozenIcePack,energyPhaseChange_pack,vaporMassEvap_pack,vaporMassSub_pack,...
    vaporFluxEvapVeg,vaporGrndSoil,vaporTransSoil)
global SECONDS_PER_HOUR
%% update thermal status, TSurf, Tcan
% canopy
this.canopy.TSurf(this.canopy.hasSnow)=Tfoliage(this.canopy.hasSnow);
this.canopy.TSurf(~this.canopy.hasSnow)=this.Tair(~this.canopy.hasSnow);
Tcanopy(~this.canopy.hasSnow)=this.Tair(~this.canopy.hasSnow);
% soil 
this.soilSurf.TSurf=Tsoil;
this.soilSurf.T1=T1Soil;
% snowpack
this.snowpack.TSurf=TSnow;
%% update states due to evaporation/sublimation/condensation
this.snowpack.destruct(this.dt*SECONDS_PER_HOUR,dCCSurf,dCCPack,refrozenIcePack,energyPhaseChange_pack,vaporMassEvap_pack,vaporMassSub_pack);
this.canopy.dripple(this.dt*SECONDS_PER_HOUR,Tcanopy,this.LAI(this.soilSurf.isOverstory),vaporFluxSub_can,actEvap_can,energyPhaseChange_can,this.soilSurf);
vaporTrans=vaporTransSoil;
vaporGrnd=vaporGrndSoil;
vaporGrnd(this.soilSurf.isOverstory)=vaporGrnd(this.soilSurf.isOverstory)+actEvapGrnd_can;
vaporTrans(this.soilSurf.isOverstory,:)=vaporTrans(this.soilSurf.isOverstory,:)+actTranspir_can;
this.soilSurf.evap(this.dt*SECONDS_PER_HOUR,vaporFluxEvapVeg,vaporGrnd,vaporTrans);
%% sum up thru rain that reaches the soil surface
rainBare=this.soilSurf.WThru;
rainBare(this.soilSurf.hasSnow)=this.snowpack.outflow(this.soilSurf.hasSnow);
%%
% 
% * ITEM1
% * ITEM2
% 
end