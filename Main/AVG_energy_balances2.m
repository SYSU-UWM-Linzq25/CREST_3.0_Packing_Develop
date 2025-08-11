function varargout=AVG_energy_balances2(T,mask,code,canopy,soilSurf,snowpack,...
                             optSoilThermal,feedback,dt,...
                             rainfall,Tair,airDens,press,eActAir,VPD,elevation,LAI,...
                             shortOverIn,shortUnder,longAtmIn,...
                             iceSurf,icePack,TThru,rainThru)
%% update history
% updated by Shen, Xinyi on Jan 14, 2019 to output PET
global SECONDS_PER_HOUR
switch code
    %% intercepted snow only
    case '11'
        Tfoliage=T(:,1);
        TCanopy=T(:,2);
        TPackSurfTemp=nan(soilSurf.nCells,1);
        TSoilTemp=T(:,3);
    case '12'
        Tfoliage=zeros(soilSurf.nCells,1);
        TCanopy=T(:,1);
        TPackSurfTemp=nan(soilSurf.nCells,1);
        TSoilTemp=T(:,2);
    %% pack snow only
    case '21'
        Tfoliage=Tair;
        TCanopy=Tair;
        TPackSurfTemp=T(:,1);
        TSoilTemp=T(:,2);
    case '22'
        Tfoliage=Tair;
        TCanopy=Tair;
        TPackSurfTemp=zeros(soilSurf.nCells,1);
        TSoilTemp=T(:,1);
    case '31'
        Tfoliage=T(:,1);
        TCanopy=T(:,2);
        TPackSurfTemp=T(:,3);
        TSoilTemp=T(:,4);
    case '32'
        Tfoliage=T(:,1);
        TCanopy=T(:,2);
        TPackSurfTemp=zeros(soilSurf.nCells,1);
        TSoilTemp=T(:,3);
    case '33'
        Tfoliage=zeros(soilSurf.nCells,1);
        TCanopy=T(:,1);
        TPackSurfTemp=T(:,2);
        TSoilTemp=T(:,3);
    case '34'
        Tfoliage=zeros(soilSurf.nCells,1);
        TCanopy=T(:,1);
        TPackSurfTemp=zeros(soilSurf.nCells,1);
        TSoilTemp=T(:,2);
    case '4'
        Tfoliage=Tair;
        TCanopy=Tair;
        TPackSurfTemp=nan(soilSurf.nCells,1);
        TSoilTemp=T(:,1);
    otherwise
        Tc1=Tair(soilSurf.isOverstory);
        Tf=Tc1;
        Tf2=T(soilSurf.isOverstory,1);
        Tf(canopy.hasSnow)=Tf2(canopy.hasSnow);
        Tfoliage=nan(soilSurf.nCells,1);
        Tfoliage(soilSurf.isOverstory)=Tf;
        
        Tc2=T(soilSurf.isOverstory,2);
        Tc=Tc1;
        Tc(canopy.hasSnow)=Tc2(canopy.hasSnow);
        TCanopy=Tair;
        TCanopy(soilSurf.isOverstory)=Tc;
        TPackSurfTemp=T(:,3);
        TSoilTemp=T(:,4);
end



% TSoilTemp=T(:,4);
% temperature of the snowpack cannot exceed 0
% TPackSurfTemp(TPackSurfTemp>0)=0;
% TCanopy=Tair;
% only canopy with intercepted snow can have Tcanopy different from Tair
% hasSurrAir=soilSurf.isOverstory;
% hasSurrAir(hasSurrAir)=canopy.hasSnow;
% TCanopy(hasSurrAir)=TcanopyTemp(hasSurrAir);
% TCanopy(~hasSurrAir)=Tair(~hasSurrAir);
% Tfoliage=TfoliageTemp;
% Tfoliage(~hasSurrAir)=Tair(~hasSurrAir);

% TCanopy(~hasSurrAir)=Tair(~(soilSurf.isOverstory&soilSurf.hasSnow));

%% mask operation
nCells=sum(mask);
isOverstoryFull=soilSurf.isOverstory&mask;
isOverstory=soilSurf.isOverstory(mask);
hasSnowPack=soilSurf.hasSnow(mask);
nCellsCan=sum(isOverstory);
maskCan=mask(soilSurf.isOverstory);
%% fluxes
[RaC_pack,sensibleHeat_pack,longPackOut,snowReflected,shortBareIn,netShort_pack]=...
    SnowPack.outwardFluxes(nCells,hasSnowPack,snowpack.roughness(mask),snowpack.adj_displacement(mask),snowpack.adj_ref_height(mask),...
                       snowpack.UAdj(mask),snowpack.RAero(mask),snowpack.albedo(mask),...              
                       TPackSurfTemp(mask),TCanopy(mask),...
                       airDens(mask),shortUnder(mask));
[RaC_soil,sensibleHeat_soil,longSoilOut,soilReflected,netShort_soil,soilSurfFlux,soilFlux1,netGrndFlux,T1Temp]=...
    SoilSurf.outwardFluxes(nCells,hasSnowPack,soilSurf.roughness(mask),soilSurf.adj_displacement(mask),soilSurf.adj_ref_height(mask),...
    soilSurf.UAdj(mask),soilSurf.RAero(mask),soilSurf.albedo(mask),...
    TSoilTemp(mask),TCanopy(mask),airDens(mask),shortBareIn,dt*SECONDS_PER_HOUR,optSoilThermal,...
    soilSurf.D1,soilSurf.D2,soilSurf.dp,soilSurf.kappa(mask,:),soilSurf.Cs(mask,:),soilSurf.T1(mask),soilSurf.T2(mask));
% short wave reflection from the understory
shortReflected=snowReflected+soilReflected;
[RaC_can,sensibleHeat_can,longOverOut,netShort_can,sensibleHeatAtm]=...
    Canopy.outwardFluxes(nCellsCan,canopy.hasSnow(maskCan),canopy.roughness(maskCan),canopy.adj_displacement(maskCan),canopy.adj_ref_height(maskCan),...
    canopy.UAdj(maskCan),canopy.RAero(maskCan),canopy.albedo(maskCan),...    
    Tfoliage(isOverstoryFull),TCanopy(isOverstoryFull),...
    airDens(isOverstoryFull),Tair(isOverstoryFull),shortOverIn(maskCan),shortReflected(isOverstory),...
    canopy.short_atten(maskCan));
% upward long wave radiation from the understory
longUnderOut=longPackOut+longSoilOut;
% downward long wave radiation to the understory 
longUnderIn=zeros(nCells,1);
longUnderIn(isOverstory)=longOverOut;
longUnderIn(~isOverstory)=longAtmIn(mask&(~soilSurf.isOverstory));
% heat flux from understory
% note that in CREST, snow flux is assumed zero because snow is a good
% insulator

hasIntSnow=false(nCells,1);
hasIntSnow(isOverstory)=canopy.hasSnow(maskCan);
% If the canopy does not have intercepted snow. the air temperature
% surounding the canopy is the air temperature,no sensible heat between the
% atm and the surrounding air and atm air exist, nor the surrounding air to
% and the canopy. the ground flux must go through (not be consumed by) the
% surrounding air to the canopy;
% Otherwise, the ground flux goes into the surrouding air to balance its
% budget
% the snow has no upward conductive heat
fluxUnder2Canopy=zeros(nCells,1);
grndfluxConductToOverstory=~(hasSnowPack|hasIntSnow);
fluxUnder2Canopy(grndfluxConductToOverstory)=soilSurfFlux(grndfluxConductToOverstory);
% soil flux to the snow pack
fluxUnder2Pack=zeros(nCells,1);
fluxUnder2Pack(hasSnowPack)=soilSurfFlux(hasSnowPack);
% if the canopy has intSnow and ground heat flux is not overshadowed by the
% snow pack, it is directly conducted to the surrounding air
grndfluxConductToAir=(~hasSnowPack) & hasIntSnow;
fluxUnderToAtm=zeros(nCells,1);
fluxUnderToAtm(grndfluxConductToAir)=soilSurfFlux(grndfluxConductToAir);
fluxUnderToAtm=fluxUnderToAtm(isOverstory);
%% netRadiation
netRad_can=Canopy.netRadiation(netShort_can,longAtmIn(isOverstoryFull),longOverOut,longUnderOut(isOverstory),fluxUnder2Canopy(isOverstory));
netRad_pack=SnowPack.netRadiation(nCells,hasSnowPack,netShort_pack,longUnderIn,longPackOut);
[netRad_soil,netRadET_soil]=SoilSurf.netRadiation(nCells,hasSnowPack,isOverstory,soilSurf.isBare(mask),...
    netShort_soil,longUnderIn,longSoilOut,soilSurfFlux,netGrndFlux);
%% latent heat
[AET_can,actEvap_can,actEvapGrnd_can,actTranspir_can,vaporFluxSub_can,latentHeat_can,PET_can]=...
    Canopy.LatentHeat(feedback,dt*SECONDS_PER_HOUR,nCellsCan,canopy.hasSnow(maskCan),...
             RaC_can,Tfoliage(isOverstoryFull),...
             eActAir(isOverstoryFull),VPD(isOverstoryFull),...
             rainfall(isOverstoryFull),Tair(isOverstoryFull),...% should be able to be replaced by TCanopy
             LAI(isOverstoryFull),elevation(isOverstoryFull),...
             airDens(isOverstoryFull),press(isOverstoryFull),...
             netShort_can,netRad_can,...
             canopy.Wm(maskCan),canopy.WOrg(maskCan),...
             soilSurf.root(isOverstoryFull,:),soilSurf.Wcr(isOverstoryFull,:), soilSurf.Wwp(isOverstoryFull,:),...
             canopy.rarc(maskCan),canopy.r0c(maskCan),canopy.RGL(maskCan),...
             soilSurf.W(isOverstoryFull,:),soilSurf.ice(isOverstoryFull,:),soilSurf.WThru(isOverstoryFull),...
             canopy.intSnow(maskCan),canopy.W(maskCan));
[vaporMassEvap_pack,vaporMassSub_pack,latentHeat_pack,PET_pack]=SnowPack.LatentHeat(dt*SECONDS_PER_HOUR,nCells,hasSnowPack,RaC_pack,TPackSurfTemp(mask),...
              eActAir(mask),VPD(mask),airDens(mask),press(mask),iceSurf(mask),icePack(mask),snowpack.W(mask));
[AET_soil,actEvap_soil,actEvapGrnd_soil,actTranspir_soil,latentHeat_soil,PET_soil]=...
    SoilSurf.LatentHeat(...
    feedback,dt*SECONDS_PER_HOUR,nCells,hasSnowPack,isOverstory,soilSurf.isBare(mask),...
    RaC_soil,TSoilTemp(mask),airDens(mask),press(mask),eActAir(mask),VPD(mask),LAI(mask),rainfall(mask),...
    elevation(mask),Tair(mask),netShort_soil,netRadET_soil,canopy.hasSnow(maskCan),...
    soilSurf.depths(1),soilSurf.rarc(mask),soilSurf.r0c(mask),soilSurf.RGL(mask),...
    soilSurf.b_infilt(mask),soilSurf.moist_resid(mask),soilSurf.WmVeg(mask),soilSurf.Wcr(mask,:),soilSurf.Wwp(mask,:),soilSurf.Wm(mask,:),...
                soilSurf.WVegOrg(mask),soilSurf.W(mask,:),soilSurf.ice(mask,:),soilSurf.root(mask,:),soilSurf.WThru(mask));        
%% energy balances
[error_can,energyPhaseChange_can]=...
    Canopy.energy_balance(nCellsCan,canopy.hasSnow(maskCan),...
              Tfoliage(isOverstoryFull),dt*SECONDS_PER_HOUR,sensibleHeat_can,latentHeat_can,netRad_can,actEvap_can,vaporFluxSub_can,...
              canopy.CH_positive,canopy.CH_negative,...
              canopy.intSnow(maskCan),canopy.W(maskCan),canopy.TSurf(maskCan),canopy.TW(maskCan));
%% if the canopy has no snow interception, its budget is directly added to the understory
error_can_add=error_can;
error_can(~canopy.hasSnow(maskCan))=0;
error_can_add(canopy.hasSnow(maskCan))=0;
[error_pack,dCCSurf,dCCPack,refrozenIcePack,energyPhaseChange_pack]=snowpack.energy_balance(nCells,hasSnowPack,isOverstory,...
                            TPackSurfTemp(mask),dt*SECONDS_PER_HOUR,...
                            netRad_pack,TThru(mask),rainThru(mask),iceSurf(mask),icePack(mask),...
                            sensibleHeat_pack,latentHeat_pack,...
                            vaporMassEvap_pack,vaporMassSub_pack,...
                            fluxUnder2Pack,error_can_add,...
                            snowpack.CH_positive,snowpack.CH_negative,snowpack.TSurf(mask),snowpack.W(mask),snowpack.WPack(mask),snowpack.CCPack(mask));
error_soil=soilSurf.energy_balance(nCells,hasSnowPack,isOverstory,...
    TSoilTemp(mask),T1Temp,dt*SECONDS_PER_HOUR,sensibleHeat_soil,latentHeat_soil,netRad_soil,error_can_add,optSoilThermal,...
    soilSurf.D1,soilSurf.D2,soilSurf.dp,...
    soilSurf.Cs(mask,:),soilSurf.TSurf(mask),soilSurf.T1(mask));
if any(isOverstory)
    sensibleHeatUnder=(sensibleHeat_pack(isOverstory)+sensibleHeat_soil(isOverstory)).*canopy.hasSnow(maskCan);
    error_Atm=Canopy.atmo_energybalance(sensibleHeatAtm,sensibleHeat_can,sensibleHeatUnder+fluxUnderToAtm);
else
    error_Atm=[];
end
error_Atm1=zeros(soilSurf.nCells,1);
error_Atm1(isOverstoryFull)=error_Atm;
error_can1=zeros(soilSurf.nCells,1);
error_can1(isOverstoryFull)=error_can;
error_pack1=zeros(soilSurf.nCells,1);
error_pack1(mask)=error_pack;
error_soil1=zeros(soilSurf.nCells,1);
error_soil1(mask)=error_soil;
if nargout==1
    switch code(1)
        case '1'
            varargout={[error_can1,error_Atm1,error_soil1]};
        case '2'
            varargout={[error_pack1,error_soil1]};
        case '3'
            varargout={[error_can1,error_Atm1,error_pack1,error_soil1]};
        case '4'
            varargout={error_soil1};
    end
else
    varargout={error_can1,error_Atm1,error_pack,error_soil,...% balances
        AET_can,actEvap_can,actEvapGrnd_can,actTranspir_can,vaporFluxSub_can,energyPhaseChange_can,...% mass transformation in the canopy layer
        vaporMassEvap_pack,vaporMassSub_pack,dCCSurf,dCCPack,refrozenIcePack,energyPhaseChange_pack,...%mass transformation in the pack layer
        AET_soil,actEvap_soil,actEvapGrnd_soil,actTranspir_soil,T1Temp,...
        PET_can,PET_pack,PET_soil};
end
end