%% update history
classdef Medium<handle
    properties(Access=public)
        nCells;
        nLayers; % numbers of soil layers
        %%% volumetric heat capacity , $$J(m^3*^oC)^{-1},\Delta$
        CH_positive;
        CH_negative;
        %%% stored liquid water depth,(mm) 
        W;
        %%% $$T_{foliage} (^oC)$ : surface temperature of the last time step
        TSurf; % for some medium, TSurf is the uniform temperature
        TW; % temperature of liquid water may deviate from TSurf after interception/compaction
       %%% liquid water capacity (mm)
        Wm;
        %%% albedo
        albedo;
        %%% (m) roughness of the medium surface
        roughness;
        %%% (mm) through liqud water(thru rain in the canopy layer, infiltration in the soil layer and outflow of the pack layer)
        WThru;
        TWThru;
        %%% $$ (sm^{-1}) $ resistance to moisture from evaporate 
        RAero;
        %%% (m/s) adjusted wind speed 
        UAdj;
        %%% (m) displacement of windspeed measurement (solely depends on vegetation height)
        displacement;
        %%%(m): reference height of the wind measurement, z
        ref_height;
        %%% adjusted displacement: the displacement after windspeed is
        %%% converted to a desired height according to the curren medium
        adj_displacement;
        %%% the desired height of wind speed and aerodynamic
        hasSnow;
    end
    methods (Access=public)
        function this=Medium(nCells,row,col,rows,cols,...
                CH_positive,CH_negative,moisture,TSurf,nLayers)
            this.nLayers=nLayers;
            this.CH_positive=CH_positive;
            this.CH_negative=CH_negative;
            this.displacement=nan(this.nCells,1);
            if this.nCells>0
                this.W=ones(this.nCells,nLayers);
                this.WThru=nan(this.nCells,nLayers);
                this.TWThru=nan(this.nCells,nLayers);
                % this.adj_displacement=nan(this.nCells,1);
                % this.adj_ref_height=nan(this.nCells,1);
                % this.RAero=nan(this.nCells,1);
                % this.UAdj=nan(this.nCells,1);
                % this.albedo=nan(this.nCells,1);
            else
                this.W=[];
                this.WThru=[];
                this.TWThru=[];
                % this.adj_displacement=[];
                % this.adj_ref_height=[];
                % this.RAero=[];
                % this.UAdj=[];
                % this.albedo=[];
            end
           %% medium moisture
            if isscalar(moisture)
                this.W=moisture*this.W;
            elseif length(moisture(:))==this.nLayers
                for iL=1:this.nLayers
                    this.W(:,iL)=moisture(iL);
                end
            elseif size(moisture,1)*size(moisture,2)==this.nCells*this.nLayers
                this.W=moisture;
            else
                error('initialize moisture with wrong input');
            end
            if this.nCells==0
                this.TSurf=[];
            elseif isscalar(TSurf)
                this.TSurf=TSurf*ones(nCells,1);
            elseif length(TSurf)==nCells
                this.TSurf=TSurf;
            else
                error('initialize Temperature with wrong input');
            end
        end
    end
    methods(Abstract)
        [error,varargout]=energy_balance(this,TTemp,dt,sensibleHeat,latentHeat,varargin)
        aerodynamic(this,varargin);
        surfaceAeroPar(this,wind_h,varargin);
        varargout=LatentHeat(this,dt,RaC,TSurfTemp,eActAir,vpd,varargin);

        
    end
    methods(Static)
        [correction,hasWind]=StabilityCorrection(nCells,UAdj,roughness,adj_displacement,adj_ref_height,TSurfTemp,Tair);
    end
    
end