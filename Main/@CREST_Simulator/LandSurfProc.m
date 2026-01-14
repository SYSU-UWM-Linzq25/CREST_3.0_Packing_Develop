function LandSurfProc(this,node,nNodes)
global SECONDS_PER_HOUR
T_canopy=[];
T_pack=[];
T_both=[];
T_no_snow=[];
%% update time variant parameters

this.canopy.updateMonthlyParameter(this.forcingVar.dateCur,this.modelPar.covers);
this.canopy.updateDailyParameter(this.LAI(this.soilSurf.isOverstory));
this.soilSurf.updateMonthlyParameter(this.forcingVar.dateCur,this.modelPar.covers);
this.soilSurf.updateDailyParameter(this.LAI);
this.soilSurf.update_thermal_properties();% per time step
%% aerodynamic
this.canopy.surfaceAeroPar(this.canopy.wind_h);
this.canopy.aerodynamic(this.wind(this.soilSurf.isOverstory),this.soilSurf.roughness(this.soilSurf.isOverstory));
this.snowpack.surfaceAeroPar(this.soilSurf.wind_h);
this.snowpack.aerodynamic(this.wind,this.canopy.height,this.canopy.trunk,...
    this.canopy.wind_atten,this.canopy.displacement,this.canopy.roughness);
this.soilSurf.surfaceAeroPar(this.soilSurf.wind_h,this.canopy.height);
this.soilSurf.aerodynamic(this.wind);
% this.drip=this.canopy.rainDrip+this.canopy.snowDrip;% test only
%% canopy interception
this.canopy.intercept(this.globalVar.optBlowSnow,false,this.Tair(this.soilSurf.isOverstory),this.LAI(this.soilSurf.isOverstory),...
this.snow(this.soilSurf.isOverstory),this.rain(this.soilSurf.isOverstory));
[shortOverIn,shortUnderIn]=this.canopy.SWPart(this.shortwave(this.soilSurf.isOverstory));
%% snow and rain that fall on the understory
%through snow
snowThru=this.snow;
snowThru(this.soilSurf.isOverstory)=this.canopy.snowThru;
%through rain
rainThru=zeros(this.soilSurf.nCells,1);
rainThru(this.soilSurf.isOverstory)=this.canopy.WThru;
rainThru(~this.soilSurf.isOverstory)=this.rain(~this.soilSurf.isOverstory);
% temperature of the through fall (snow & rain)
TWThru=this.Tair;
TWThru(this.soilSurf.isOverstory)=this.canopy.TWThru;
TSnowThru=this.Tair;
TSnowThru(this.soilSurf.isOverstory)=this.canopy.TThruSnow;
shortUnder=this.shortwave;
shortUnder(this.soilSurf.isOverstory)=shortUnderIn;
%% snow compation
[iceSurf,icePack]=this.snowpack.compact(this.dt,this.forcingVar.dateCur,...
    this.basicVar.lat(this.basicVar.basinMask),rainThru,snowThru,TSnowThru);
this.soilSurf.hasSnow=this.snowpack.hasSnow;
%% short vegetation interception
this.soilSurf.intercept(this.globalVar.feedback,rainThru.*(~this.soilSurf.hasSnow));

%% uncomment to save the state variables
% [fileToSave,subName]=StateVariables.GenerateOutVarNames(this.globalVar.statePath,this.forcingVar.dateCur,...
%     this.globalVar.saveDateFormat,this.forcingVar.fmtSubDir,this.forcingVar.pathSplitor,node,nNodes);
% subT=['T_',subName];
% subnNotConv1=['nNotConv1_',subName];
% subnNotConv2=['nNotConv2_',subName];
% subnNotConv3=['nNotConv3_',subName];
% subnNotConv4=['nNotConv4_',subName];
% subit1=['it1',subName];
% subit2=['it2',subName];
% subit3=['it3',subName];
% subit4=['it4',subName];
% 
% if exist(fileToSave,'file')==2
%     try
%         load(fileToSave,subT);
%         cmd=['T=S.',subT,';'];
%         eval(cmd);
%         load(fileToSave,subnNotConv1);
%         cmd1=['nNotConv1=S.',subnNotConv1,';'];
%         eval(cmd1);
%         cmd2=['nNotConv2=S.',subnNotConv2,';'];
%         eval(cmd2);
%         cmd3=['nNotConv3=S.',subnNotConv3,';'];
%         eval(cmd3);
%         cmd4=['nNotConv4=S.',subnNotConv4,';'];
%         eval(cmd4);
%         existed=true;
%     catch
%         existed=false;
%     end
% end
% if ~existed
%% solve temperatures using the broyden method
    %% energy balances: solve for medium temperature iteratively
    %%% set initial guess of the temperatures
    T=nan(this.nCells,4);
    % initial guess of Tfoliage, if has intercepted snow, set to zero,
    % otherwise, zero
    % no snow at all
    if this.canopy.nCells>0
       Tf=zeros(this.canopy.nCells,1);
    else
       Tf=[];
    end
    Tf(this.canopy.hasSnow&this.canopy.TSurf<0)=this.canopy.TSurf(this.canopy.hasSnow&this.canopy.TSurf<0);
    Tf(~this.canopy.hasSnow)=NaN;
    T(this.soilSurf.isOverstory,1)=Tf;
    % initial guess of TCanopy
    Tc=this.Tair(this.soilSurf.isOverstory);
    Tc(~this.canopy.hasSnow)=NaN;
    T(this.soilSurf.isOverstory,2)=Tc;
    T(~this.soilSurf.isOverstory,2)=NaN;
    % initial guess of TSnowSurf
%     T(this.snowpack.hasSnow,3)=this.Tair(this.snowpack.hasSnow);
    T(this.snowpack.hasSnow,3)=this.snowpack.TSurf(this.snowpack.hasSnow);%+this.Tair(this.snowpack.hasSnow))/2;
    T(~this.snowpack.hasSnow,3)=NaN;
    % initial gues of TSoilSurf
    T(:,4)=this.soilSurf.TSurf;
    T(~this.soilSurf.hasSnow,4)=this.Tair(~this.soilSurf.hasSnow);
    
    % case 1 both canopy and soil has snow
    mask1=this.soilSurf.hasSnow&this.soilSurf.isOverstory;
    % case 2 only canopy has Snow
    mask2=(~this.soilSurf.hasSnow)&this.soilSurf.isOverstory;
    % case 3 only the snow pack exists
    mask3=this.soilSurf.hasSnow;
    % case 4 no snow
    mask4=~this.soilSurf.hasSnow;
    if sum(this.soilSurf.isOverstory)>0
        mask1(this.soilSurf.isOverstory)=mask1(this.soilSurf.isOverstory)&this.canopy.hasSnow;
        mask2(this.soilSurf.isOverstory)=mask2(this.soilSurf.isOverstory)&this.canopy.hasSnow;
        mask3(this.soilSurf.isOverstory)=mask3(this.soilSurf.isOverstory)&(~this.canopy.hasSnow);
        mask4(this.soilSurf.isOverstory)=mask4(this.soilSurf.isOverstory)&(~this.canopy.hasSnow);
    end
%     tic
    T0=T;
    [T,nNotConv1,it1]=solveLandProc(this,T,mask2,'canopy_only',iceSurf,icePack,TWThru,rainThru,shortOverIn,shortUnder);
    [T,nNotConv2,it2]=solveLandProc(this,T,mask3,'pack_only',iceSurf,icePack,TWThru,rainThru,shortOverIn,shortUnder);
    [T,nNotConv3,it3]=solveLandProc(this,T,mask1,'both',iceSurf,icePack,TWThru,rainThru,shortOverIn,shortUnder);
    [T,nNotConv4,it4]=solveLandProc(this,T,mask4,'no_snow',iceSurf,icePack,TWThru,rainThru,shortOverIn,shortUnder);
    %% temperature is restored if exceeds limits
    maskIm=(T<-70 | T>70);
    T(maskIm)=T0(maskIm);
    this.numOfImpossibleT=this.numOfImpossibleT+sum(sum(maskIm)>0,2);
    this.numOfNotConv=this.numOfNotConv+nNotConv1+nNotConv2+nNotConv3+nNotConv4;
%     if any(T(:)<-70 | T(:)>70)
%         error('impossible temperature')
%     end
%     toc
%% uncomment to enable state variables 
%     cmd=[subT,'=T;'];
%     cmd1=[subnNotConv1,'=nNotConv1;'];
%     cmd2=[subnNotConv2,'=nNotConv2;'];
%     cmd3=[subnNotConv3,'=nNotConv3;'];
%     cmd4=[subnNotConv4,'=nNotConv4;'];
%     cmd5=[subit1,'=it1;'];
%     cmd6=[subit2,'=it2;'];
%     cmd7=[subit3,'=it3;'];
%     cmd8=[subit4,'=it4;'];
%     eval(cmd);
% eval(cmd1);eval(cmd2);eval(cmd3);eval(cmd4);eval(cmd5);eval(cmd6);eval(cmd7);eval(cmd8);
%     if exist(fileToSave,'file')~=2
%         save(fileToSave,subT,'-v7.3');
%             subnNotConv1,subnNotConv2,subnNotConv3,subnNotConv4,...
%             subit1,subit3,subit3,subit4,'-v7.3');
%     else
%         save(fileToSave,subT,'-append');...
%             subnNotConv1,subnNotConv2,subnNotConv3,subnNotConv4,...
%             subit1,subit3,subit3,subit4,'-append');
%     end
% end


% disp(['case 1: maximal iteration: ',num2str(it1),'; ', num2str(nNotConv1), ' cells not converged' ]);
% disp(['case 2: maximal iteration: ',num2str(it2),'; ', num2str(nNotConv2), ' cells not converged' ]);
% disp(['case 3: maximal iteration: ',num2str(it3),'; ', num2str(nNotConv3), ' cells not converged' ]);
% disp(['case 4: maximal iteration: ',num2str(it4),'; ', num2str(nNotConv4), ' cells not converged' ]);
% disp('energy balance time')
% tic
mask=true(this.nCells,1);
[error_can,error_Atm,error_pack,error_soil,...% balances
          AET_can,actEvap_can,actEvapGrnd_can,actTranspir_can,vaporFluxSub_can,energyPhaseChange_can,...% mass transformation in the canopy layer
          vaporMassEvap_pack,vaporMassSub_pack,dCCSurf,dCCPack,refrozenIcePack,energyPhaseChange_pack,...%mass transformation in the pack layer
          AET_soil,evap_soil,evapGrnd_soil,transpir_soil,T1,...
          PET_can,PET_pack,PET_soil]=AVG_energy_balances2(T,mask,'',this.canopy,this.soilSurf,this.snowpack,...
                             this.modelPar.optSoilThermal,this.modelPar.evapSurfWater,this.dt,...%mass transformation in the soil layer
                             this.rain,this.Tair,this.airDens,this.pressure,this.eAct,this.VPD,...
                             this.basicVar.DEM(this.basicVar.basinMask),this.LAI,...
                             shortOverIn,shortUnder,this.longwave,...
                             iceSurf,icePack,TWThru,rainThru);
% toc
this.EAct=AET_soil;
this.EAct(this.soilSurf.isOverstory)=this.EAct(this.soilSurf.isOverstory)+AET_can;
this.EAct=this.EAct+vaporMassEvap_pack+vaporMassSub_pack;
this.EAct=-this.EAct*this.dt*SECONDS_PER_HOUR;

this.PET=PET_soil+PET_pack;
this.PET(this.soilSurf.isOverstory)=this.PET(this.soilSurf.isOverstory)+PET_can;
this.PET=-this.PET*this.dt*SECONDS_PER_HOUR;

this.actTranspir=transpir_soil;
this.actTranspir(this.soilSurf.isOverstory,:)=this.actTranspir(this.soilSurf.isOverstory,:)+actTranspir_can;
this.actTranspir=-this.actTranspir*this.dt*SECONDS_PER_HOUR;

this.rainBare=this.updateAllMedium(T(this.soilSurf.isOverstory,1),T(this.soilSurf.isOverstory,2),T(:,3),T(:,4),T1,...
    vaporFluxSub_can,actEvap_can,actEvapGrnd_can,actTranspir_can,energyPhaseChange_can,...
    dCCSurf,dCCPack,refrozenIcePack,energyPhaseChange_pack,vaporMassEvap_pack,vaporMassSub_pack,...
    evap_soil,evapGrnd_soil,transpir_soil);

this.soilSurf.runoffGen(this.rainBare,'linear',this.modelPar.IM(this.modelPar.basinMask));

end