function EBTest()
define_constant();
global m2mm
index=[(1:12)';(1:12)';(1:12)'];
nCells=length(index);
k=12;
g=3;
dt=1;
optBlowSnow=1;
feedback=false;
evapSurfWater=true;
% date
date=datenum(1991,5,1);
% nCells=20;
%% initialize medium
libPath='E:\Simulation\CoverLib.csv';
% optSoilThermal='Countinuous_Neumann';
optSoilThermal='VIC_410';%'Independent_Balances';%
MIN_RAIN_TEMP=-0.5;
MAX_SNOW_TEMP=0.5;
%% temporay pars that will be later imported from soil grids
roughSoil=0.01*ones(nCells,1);
roughPack=0.03;
covers=Cover.ReadVegLib(libPath);

% create the Soil Surface object
depth=[0.1;0.3;1.5];
dp=4;
%% change according to VIC before DEBUG
b_infilt=0.3*ones(nCells,1);
nLayers=3;
moist_resid=0.05*ones(nCells,1);
soil_dense_min=InitLayeredVar(2619.1,nCells,nLayers);
bulk_dens_min=InitLayeredVar(1569.1,nCells,nLayers);
organic=InitLayeredVar(0,nCells,nLayers);
soil_density=InitLayeredVar(2619.1,nCells,nLayers);
bulk_density=InitLayeredVar(1569.1,nCells,nLayers);
quartz=InitLayeredVar(0.693,nCells,nLayers);
Wcr=InitLayeredVar(0.1251,nCells,nLayers);
Wwp=InitLayeredVar(0.07377,nCells,nLayers);
soilSurf=SoilSurf(nLayers,depth,dp,nCells,index,covers,roughSoil,...
    b_infilt,moist_resid,soil_dense_min,bulk_dens_min,soil_density,bulk_density,quartz,organic,...
    Wcr,Wwp);
% create a Snow Pack object
snowpack=SnowPack(nCells,roughPack);
snowpack.isOverstory=soilSurf.isOverstory;
%create a Canopy object
canopy=Canopy(index(soilSurf.isOverstory),covers);
% canopy.hasSnow= true(nCells,1);
%% fake forcing data
prec=createPar([15.57 155.3398 15.53],k);
Tair=createPar([23.76;-11.184;-11.184],k);
shortwave=createPar([5000;0;0],k);
wind=4.51*ones(nCells,1);
LAI=3.4*ones(nCells,1);
eActAir=137.94573768499919*ones(nCells,1);
VPD=27.48*ones(nCells,1);
elevation=1726.542*ones(nCells,1);
airDens=1.082*ones(nCells,1);
lat=48.3125*ones(nCells,1);
press=80194.463*ones(nCells,1);
roughness_surf=0.01*ones(nCells,1);
longAtmIn=204.82*ones(nCells,1);
%% fake solution
% case 1
TcanopyTemp=createPar([23.76;-11.8;-11.8],canopy.nCells/g);
TfoliageTemp=createPar([23.76;-12.87;-12.87],canopy.nCells/g);
TPackSurfTemp=createPar([NaN;-4.94;-9.75],k);
TSoilTemp=createPar([31.23 -11.18 -11.18],k);
% TcanopyTemp=-11.18*ones(canopy.nCells,1);
% TfoliageTemp=-12.87*ones(canopy.nCells,1);
% TPackSurfTemp=-4.94*ones(nCells,1);
% TSoilTemp=-11.18*ones(nCells,1);
%% fake status variables that will be provided by state files
% canopy
% canopy.intSnow=0*ones(canopy.nCells,1);
% canopy.W(:)=0*ones(canopy.nCells,1);
canopy.TSurf=createPar([23.76;-10.206;-10.206],canopy.nCells/g);
% soil Surface
soilSurf.W=InitLayeredVar(0.15442,nCells,soilSurf.nLayers);
% soilSurf.W(:,2)=0.46327;
soilSurf.W(:,3)=0.1029;
for iL=1:soilSurf.nLayers
    soilSurf.W(:,iL)=soilSurf.W(:,iL)*soilSurf.depths(iL)*m2mm;
end
soilSurf.TSurf=createPar([10;-1;-1],k);
soilSurf.T1=createPar([2;-1;-1],k);
soilSurf.T2=0.3025*ones(nCells,1);
%% fluxes that will eventually be calculated insided of the model
% longUnderOut=311.01817907317371*ones(nCells,1);
% shortReflected=zeros(nCells,1);
%% update time variant parameters
canopy.updateMonthlyParameter(date,covers);
canopy.updateDailyParameter(LAI(soilSurf.isOverstory));
soilSurf.updateMonthlyParameter(date,covers);
soilSurf.updateDailyParameter(LAI);
soilSurf.update_thermal_properties();% per time step
%% aerodynamic
canopy.surfaceAeroPar(canopy.wind_h);
canopy.aerodynamic(wind(soilSurf.isOverstory),roughness_surf(soilSurf.isOverstory));
% snowpack.hasSnow=snowfall-canopy.intSnow>0;% change later
snowpack.surfaceAeroPar(soilSurf.wind_h);
snowpack.aerodynamic(wind,canopy.height,canopy.trunk,canopy.wind_atten,canopy.displacement,canopy.roughness);
soilSurf.surfaceAeroPar(soilSurf.wind_h,canopy.height);
soilSurf.aerodynamic(wind);
%% separate snow fall and rain fall from total precipitation
[rainfall,snowfall]=partRainAndSnow(Tair,prec,MIN_RAIN_TEMP,MAX_SNOW_TEMP);
% snowfall=prec-rainfall;
%% canopy interception
canopy.intercept(optBlowSnow,false,TcanopyTemp,LAI(soilSurf.isOverstory),...
    snowfall(soilSurf.isOverstory),rainfall(soilSurf.isOverstory));
[shortOverIn,shortUnderIn]=canopy.SWPart(shortwave(soilSurf.isOverstory));
%% snow and rain that fall on the understory
%through snow
snowThru=snowfall;
snowThru(soilSurf.isOverstory)=canopy.snowThru;
%through rain
rainThru=zeros(soilSurf.nCells,1);
rainThru(soilSurf.isOverstory)=canopy.WThru;
rainThru(~soilSurf.isOverstory)=rainfall(~soilSurf.isOverstory);
% temperature of the through fall (snow & rain)
TThru=Tair;
TThru(soilSurf.isOverstory)=canopy.TThruSnow;
shortUnder=shortwave;
shortUnder(soilSurf.isOverstory)=shortUnderIn;
%% snow compation
[iceSurf,icePack]=snowpack.compact(dt,date,lat,rainThru,snowThru,TThru);
soilSurf.hasSnow=snowpack.hasSnow;
%% short vegetation interception
soilSurf.intercept(feedback,rainThru.*(~soilSurf.hasSnow));
%% Medium temperature dependent routines must be computed iteratively
T=nan(soilSurf.nCells,4);
% initial guess of Tfoliage
T(soilSurf.isOverstory,1)=canopy.TSurf;
T(soilSurf.isOverstory(~canopy.hasSnow),1)=NaN;
% initial guess of TCanopy
T(:,2)=Tair;
T(~soilSurf.isOverstory,2)=NaN;
T(soilSurf.isOverstory(~canopy.hasSnow),2)=NaN;
% initial guess of TSnowSurf
T(:,3)=snowpack.TSurf;
T(~snowpack.hasSnow,3)=NaN;
% initial gues of TSoilSurf
T(:,4)=soilSurf.TSurf;
%% solve energy balances
tol=1e-2;
tic
[Tsol,it]=broyden_v(T,@AVG_energy_balances2,4,tol,canopy,soilSurf,snowpack,...
                             optSoilThermal,evapSurfWater,dt,...%mass transformation in the soil layer
                             rainfall,Tair,airDens,press,eActAir,VPD,elevation,LAI,...
                             shortOverIn,shortUnder,longAtmIn,...
                             iceSurf,icePack,TThru,rainThru);
toc
mask=true(soilSurf.nCells,1);
[error_can,error_Atm,error_pack,error_soil,...% balances
          actEvap_can,actTranspir_can,vaporFluxSub_can,energyPhaseChange_can,...% mass transformation in the canopy layer
          vaporMassEvap_pack,vaporMassSub_pack,dCCSurf,dCCPack,refrozenIcePack,energyPhaseChange_pack,...%mass transformation in the pack layer
          actEvap_soil,actEvapGrnd_soil,actTranspir_soil]=AVG_energy_balances2(Tsol,mask,canopy,soilSurf,snowpack,...
                             optSoilThermal,evapSurfWater,dt,...%mass transformation in the soil layer
                             rainfall,Tair,airDens,press,eActAir,VPD,elevation,LAI,...
                             shortOverIn,shortUnder,longAtmIn,...
                             iceSurf,icePack,TThru,rainThru);
%% update state variables
rainBare=updateAllMedium(dt,canopy,snowpack,soilSurf,...
    LAI,...
    TcanopyTemp,vaporFluxSub_can,actEvap_can,actTranspir_can,energyPhaseChange_can,...
    dCCSurf,dCCPack,refrozenIcePack,energyPhaseChange_pack,vaporMassEvap_pack,vaporMassSub_pack,...
    actEvap_soil,actEvapGrnd_soil,actTranspir_soil);
soilSurf.runoffGen(rainBare,'exponential');
end
function var=createPar(par,nCells)
par=par(:);
var=par*ones(1,nCells);
var=var.';
var=var(:);
end
function var=InitLayeredVar(val,nCells,nLayers)
var=val*ones(nCells,nLayers);
end