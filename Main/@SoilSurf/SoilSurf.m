%% upgrade history
% 1) prepare to replace basinMask by (row, col, rows,cols)
classdef SoilSurf<Medium
    properties
       %% 2d parameters due to layered soil
        % Var(:,i) is a property in the ith layer
        kappa; % thermal conductivity
        Cs; % heat capacity 
        soil_dens_min;% $$kgm^{-3}:$ mineral soil particle density 
        bulk_dens_min; % $$kgm^{-3}:$ mineral soil bulk density
        soil_density;  % $$kg m^{-3}:$ soil particle density 
        bulk_density; % $$kg m^{-3}:$ soil bulk density
        organic;% total soil organic content (fraction of total solid soil volume)
                % i.e., organic fraction of solid soil = organic*(1-porosity)
                % mineral fraction of solid soil = (1-organic)*(1-porosity)
        quartz; %  mineral soil quartz content (fraction of mineral soil volume)
        root% root fraction in each soil
        Ksat;% saturated conductivity (mm/timestep)
        FC; % Field Capacity (mm)
        Wcr; % $$W_{cr} (mm):$ critical point of soil moisture
        Wwp; % $$W_{wp} (mm):$ wilting point of soil moisture
        depths;%(m) depths of all layers
        ice%(mm) if soil is frozen,part of the water is ice
        Wperc;% percolated water
        WOrg;% soil moisture of the last time step
        ExcS;% (mm)overland excessive water
        ExcI;% (mm)subsurface excessive water
%         soil_fract;
       %% other parameters
        index; % cover class; the index property of the SoilSurf class is the same as that of the Canopy class but contains more types with no overstory structure
        T1;%(C) time-variant temperature at the bottom of the surface layer
        T2;%(C) time-invariant temperature at inifite depth
        dp;%(m) diurnal damping depth
        b_infilt;% b coefficient of the infiltration curve
        WMM;% WMM=WM(:,1)*(1+b_infilt)
        IM;
        moist_resid;% minimal volumetric soil moisture mm/mm
        D1;%(m) surface layer depth (5cm usually)
        D2;%(m) first layer depth arbitrary satisfies D2>D1
        isOverstory;% boolean indicates that does the vegetation cover have a canopy layer
        isBare;% boolean indicates whether a bare soil cell
       %% variables below this secions are parameters/state variables of dwarf vegetation
        % v(this.isBare|thius.isOverstory)=NaN
        r0c;% $$ r_{0c} (sm^{-1}) $$ 
            % :minimum canopy resistance
        RGL;% (W/m^2): Value of solar radiation below which will be no transpiration (ranges from 
            %~30 W/m^2 for trees to ~100 W/m^2 for crops)
        rarc;% $$ r_{arc}(sm^{-1}): $$
        % canopy architectural resistance of evaporation
        height;% vegetation height if covered by vegatation;converted from roughness if bare;
        WVeg; % intercepted water by vegation of no canopy layer
        WmVeg;% water capacity of vegetation of no canopy layer
        WVegOrg;
        wind_h;% wind_h
    end
    methods(Access=public)
        function this=SoilSurf(row,col,rows,cols,modelPar,filePar,dt,node,nNodes)
            [dirPar,~,~]=fileparts(filePar);
            fileSurf=[dirPar,'/soilSurf_',num2str(node),'_',num2str(nNodes),'.mat'];
            nCells=sum(sum(modelPar.tileMask));
            %% 1)
            this=this@Medium(nCells,row,col,rows,cols,...
                NaN,NaN,NaN,NaN,modelPar.nLayers);
            %% end 1)

            if exist(fileSurf,'file')==2
                load(fileSurf);
                return;
            end
            global m2mm BARE_SOIL_ALBEDO
            
            %soil thermal properties are calculated dynamically based on
            %the current soil moisture
            classMap=modelPar.LCC1(modelPar.tileMask); % TileMask for Part load - Aug 30th 2025 - Linzq25
            [uc,~,ic]=unique(classMap);
            order=Cover.GetOrder(modelPar.covers,uc);
            this.index=order(ic);

            this.isOverstory=logical([modelPar.covers(this.index).isOverstory]');
            this.isBare=logical([modelPar.covers(this.index).isBare]');
            this.D1=modelPar.depths(1);
            % note that the water layer is different than the thermal layer
            this.D2=modelPar.depths(1);
            this.depths=modelPar.depths;
            this.dp=modelPar.dp;
%             this.hasSnow=zeros(nCellsWithCanopy,1);
            this.rarc=[modelPar.covers(this.index).rarc]';
            this.r0c=[modelPar.covers(this.index).rmin]';
            this.RGL=[modelPar.covers(this.index).RGL]';
            this.rarc(this.isOverstory)=NaN;
            this.RGL(this.isOverstory)=NaN;
            this.r0c(this.isOverstory)=NaN;
           %% this may be replaced
            this.wind_h=double([modelPar.covers(this.index).wind_h]');
            this.roughness=modelPar.soilRgh(modelPar.tileMask); % TileMask for Part load - Aug 30th 2025 - Linzq25
            this.roughness(~(this.isBare|this.isOverstory))=NaN;
%             this.displacement(this.isBare|this.isOverstory)=this.roughness(this.isBare|this.isOverstory)/0.123*(2/3);
            this.albedo(this.isBare|this.isOverstory)=BARE_SOIL_ALBEDO;
           %% infiltration curve parameter
            this.b_infilt=modelPar.B(modelPar.tileMask); % TileMask for Part load - Aug 30th 2025 - Linzq25
           %% soil layered properties
            % hydraulic properties
            this.FC=this.RedistVar(modelPar.FC,modelPar.depthFC,modelPar.tileMask,'weighted_adding',true,0.01); % TileMask for Part load - Aug 30th 2025 - Linzq25
            modelPar.FC=[];
            this.Wm=this.RedistVar(modelPar.Sat,modelPar.depthSat,modelPar.tileMask,'weighted_adding',true,0.01); % TileMask for Part load - Aug 30th 2025 - Linzq25
            modelPar.Sat=[];
            this.Wwp=this.RedistVar(modelPar.Wwp,modelPar.depthWwp,modelPar.tileMask,'weighted_adding',true,0.01); % TileMask for Part load - Aug 30th 2025 - Linzq25
            modelPar.Wwp=[];
            this.Wcr=(1-0.4)*(this.FC-this.Wwp)+this.Wwp;
            this.Ksat=this.RedistVar(modelPar.Ksat,modelPar.depthKsat,modelPar.tileMask,'min',false,dt); % TileMask for Part load - Aug 30th 2025 - Linzq25
            modelPar.Ksat=[];
            this.Wwp(this.isBare)=NaN;
            this.Wcr(this.isBare)=NaN;
            % soil properties
            this.organic=this.RedistVar(modelPar.OM,modelPar.depthOM,modelPar.tileMask,'weighted_adding',false,0.01); % TileMask for Part load - Aug 30th 2025 - Linzq25
            modelPar.OM=[];
            this.bulk_density=this.RedistVar(modelPar.bd,modelPar.depthbd,modelPar.tileMask,'weighted_adding',false,1); % TileMask for Part load - Aug 30th 2025 - Linzq25
            modelPar.bd=[];
           %% single layer/uniform properties
            this.moist_resid=modelPar.mvRes(modelPar.tileMask)*m2mm*this.depths(1); % TileMask for Part load - Aug 30th 2025 - Linzq25
            this.quartz=zeros(this.nCells,this.nLayers);
            for l=1:this.nLayers
                this.quartz(:,l)=modelPar.soilQuartz(modelPar.tileMask); % TileMask for Part load - Aug 30th 2025 - Linzq25
            end
            this.CalSoilDensity();
            this.soil_dens_min=this.soil_density;
            this.bulk_dens_min=this.bulk_density;
            this.WVeg=nan(this.nCells,1);
%             this.WVeg(~(this.isOverstory|this.isBare))=0;
            this.ice=nan(this.nCells,this.nLayers);
            this.Wperc=nan(this.nCells,this.nLayers);
            this.WmVeg=nan(this.nCells,1);
            this.lakeFrac=zeros(this.nCells,1);
            this.CalRoot(modelPar.covers);
            save([dirPar,'/soilSurf_',num2str(node),'.mat'], 'this');
        end
        preset(this,stateVar,forcingVar);
        updateMonthlyParameter(this,date,covers);
        updateDailyParameter(this,LAI);
        intercept(this,feedback,rainfall);
        [Ra,windAdj]=aerodynamic(this,wind,displacement,ref_height);
        surfaceAeroPar(this);
        update_thermal_properties(this);
        runoffGen(this,rainfall,optInfil,IM);
    end
    methods (Access=private)
        CalRootFrac(this,covers);
        CalSoilDensity(this);
        infiltrate(this,optInfil,Qd);
        layeredVar=RedistVar(this,varExt,varExtDepths,basinMask,method,scaledByDepth,percent2abs);
    end
    methods (Static)
        [RaC,sensibleHeat,longUpward,shortReflected,netShort,grndFlux,grndFlux1,netGrndFlux,T1Temp]=...
            outwardFluxes(nCells,hasSnow,roughness,adj_displacement,adj_ref_height,...
               UAdj,RAero,albedo,...
               TSurfTemp,Tair,airDens,...
               shortBareIn,dt,optSoilThermal,...
               D1,D2,dp,kappa,Cs,T1,T2);
        [T1Temp,grndFlux,grndFlux1,netGrndFlux]=nextT1(D1,D2,dp,kappa,Cs,...
                                 TSurfTemp,T1,T2,dt,optSoilThermal);
        [netBareRad,netBareRadET]=netRadiation(nCells,hasSnow,isOverstory,isBare,...
            netShortBare,longBareIn,longBareOut,grndFlux,netGrndflux);
        [evapSoil,evapGrnd,PETBare] =arno_evap(nCells,hasSnow,isOverstory,isBare,feedback,dt,...
                                       netRad,Tair,VPD,elevation,RaC,hasCanopySnow,...
                                       b_infilt,moist_resid,Wm,depth,...
                                       SS0,W);
        [AET,actEvapCanopy,actEvapGrnd,actTranspir,latentHeat,PET]=...
            LatentHeat(feedback,dt,nCells,hasSnow,isOverstory,isBare,...
                RaC,TSurfTemp,airDens,press,eActAir,VPD,LAI,rainfall,...
                elevation,Tair,netShort,netRadET,hasCanopySnow,...
                depth1,rarc,r0c,RGL,b_infilt,moist_resid,WmVeg,Wcr,Wwp,Wm,...
                WVegOrg,W,ice,root,SS0);
         error=energy_balance(nCells,hasSnow,isOverstory,...
                   TSurfTemp,T1Temp,dt,sensibleHeat,latentHeat,netBareRad,errorCanopy,optSoilThermal,...
                   D1,D2,dp,...
                   Cs,TSurf,T1);
    end
end