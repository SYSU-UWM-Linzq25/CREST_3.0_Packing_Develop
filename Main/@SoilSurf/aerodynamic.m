function aerodynamic(this,wind)
%% Algorithm Description
% calculate the 2m-above surface aerodynamic resistance and adjust wind speed
% For bare soil surface, displacement and roughness comes from the soil roughness;
% For vegetated area (regardless whether it is overstory), displacement and
% roughness comes from plant height and vegetation roughness respectively,
% which means the adjusted wind speed and resistence is above the
% vegetation surface.
% Note that the aerodynamic resistence and wind speed above the canopy
% layer is calculated in the Canopy class and set NaN in this function
%
% Snow packed cells are also computed as normal because the
% evapotranspiration is assumed not affected considering no snow
% interception at all
%
% Bare soil cells with snow pack are also set NaN because no
% evaporation/sensible heat exchange
% will take place
%% output
% Ra: aerodynamic resistance (s/m)
% windAdj: adjusted wind speed at desired height (2m)
%% input 
% Z0_SOIL, soil roughness
% wind,             adjusted wind speed
% displacement,  vegetation displacement 
% ref_height,    vegetation reference height
%% main routine
global Von_K HUGE_RESIST
K2=Von_K^2;
windAdj  = log((this.adj_ref_height + this.roughness-this.adj_displacement)./this.roughness)./...
    log((this.ref_height - this.displacement)./this.roughness);
% this equation is suspicious
Ra = log((this.adj_ref_height + (1.0/0.63 - 1.0) * this.displacement) ./ this.roughness).*...
  log((this.adj_ref_height + (1.0/0.63 - 1.0) * this.displacement) ./ (0.1*this.roughness)) / K2;
hasWind=wind>0;
Ra(~hasWind)=HUGE_RESIST;
this.UAdj=windAdj.*wind;
this.RAero(hasWind)=Ra(hasWind)./wind(hasWind);
this.RAero(~hasWind)=HUGE_RESIST;
%% RaC values are used for both sensible heat and latent heat
% there is neither sensible nor latent heat from the surface soil/short vegetation if it is
% coverred by snow
% this.UAdj(this.hasSnow)=NaN;
% this.RAero(this.hasSnow)=NaN;
end