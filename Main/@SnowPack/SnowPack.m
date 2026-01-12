classdef SnowPack<Medium
    % snow pack is a two lower medium including the surface layer and the
    % lower (pack) layer
    % unlike the canopy layer, this medium exists at all cells because any
    % cell has a chance of gaining snow
    properties
        CCSurf;% cold content of the surface layer
        CCPack;% cold content of the pack layer
        swqTotal;%(mm) snow+rain water equivalence
        WPack; %(mm) water depth in the pack layer 
        TPack; %(C) average temperature of the pack layer
        %%% snow density $$kg/m^3$
        density;
        %%% snow depth (m)
        depth;
        isOverstory;
        melting;
        last_snow;
        outflow;
    end
    methods
        function this=SnowPack(nCells,isOverstory,modelPar)
            % roughness: initial snow roughness from parameter file
            global CH_WATER CH_ICE
            this=this@Medium(nCells,CH_WATER,CH_ICE,NaN,NaN,1);
            this.roughness=modelPar.snowRgh(modelPar.tileMask); % TileMask for Part load - Aug 30th 2025 - Linzq25
            this.isOverstory=isOverstory;
            this.swqTotal=nan(this.nCells,1);
            this.CCPack=nan(this.nCells,1);
            this.CCSurf=nan(this.nCells,1);
            this.WPack=nan(this.nCells,1);
            this.TPack=nan(this.nCells,1);
            this.melting=false(this.nCells,1);
            this.last_snow=false(this.nCells,1);
            this.hasSnow=false(this.nCells,1);
        end
        preset(this);
        [iceSurf,icePack]=compact(this,dt,date,lat,rainfall,snowfall,TSnow);
        destruct(this,dt,dCCSurf,dCCPack,refrozenIcePack,energyPhaseChange,vaporMassEvap,vaporMassSub);
        surfaceAeroPar(this,wind_h);
        aerodynamic(this,height,trunk,roughness_surf,n,displacement,wind,ref_height);
    end
    methods(Access=private)
        updateAge(this,new_snow);
        updateAlbedo(this,dt,new_snow);
        updateMeltingStatus(this,date,lat,new_snow);
        removeRoundingError(this,th)
    end
    methods(Static)
        [RaC,sensibleHeat,longPackOut,shortReflected,shortBareIn,netShort]=outwardFluxes(...
            nCells,hasSnow,roughness,adj_displacement,adj_ref_height,...
              UAdj,RAero,albedo,...
              TSurfTemp,TAirTemp,...
              airDens,shortUnderIn);
        netRad=netRadiation(nCells,hasSnow,netShortPack,longUnderIn,longPackOut);
        [vaporMassEvap,vaporMassSub,latentHeat,vaporMassFlux]=LatentHeat(...
                dt,nCells,hasSnow,RaC,TSnowSurfTemp,eActAir,vpd,airDens,press,...
                iceSurf,icePack,W);
        [error,dCCSurf,dCCPack,refrozenIcePack,energyPhaseChange]=energy_balance(nCells,hasSnow,isOverstory,TSurfTemp,dt,...
                            netRad,TRain,rainfall,iceSurf,icePack,...
                            sensibleHeat,latentHeat,...
                            vaporMassEvap,vaporMassSub,...
                            groundFlux,errorCanopy,...
                            CH_positive,CH_negative,...
                            TSurf,W,WPack,CCPack);
        [outflow,remLiquid]=infiltrate(ice,liquid);
    end
end