function aerodynamic(this,wind,roughness_surf)
%% algorithm description
% calculate the aerodynamic resistance and adjust wind speed above canopy top
%% output
% Ra: aerodynamic resistance (s/m)
% windAdj: adjusted wind speed 2m above the canopy top
%% input (cells without a canopy layer has been ruled out before entering this function)
%
% roughness_surf, soil roughness
%
% wind,         % wind (m/s): wind speed at the near-surface reference height, above canopy $$U_z$
%
% displacement,  vegetation displacement
%% main routine
if isempty(wind)
    wind=[];
    roughness_surf=[];
end
global Von_K HUGE_RESIST
K2=Von_K^2;
Zw = 1.5 * this.height - 0.5 * this.displacement;
Zt = this.trunk.* this.height;
erroneousHeight=Zt < roughness_surf;
this.RAero= log((this.ref_height-this.displacement)./this.roughness)/K2.*...
     (this.height./(this.wind_atten.*(Zw-this.displacement)).*...
     (exp(this.wind_atten.*(1-(this.displacement+this.roughness)./this.height))-1)+...
       (Zw-this.height)./(Zw-this.displacement)+...
         log((this.ref_height-this.displacement)./(Zw-this.displacement)));
% log part
Uw = log((Zw-this.displacement)./this.roughness) ./ log((this.ref_height-this.displacement)./this.roughness);
Uh = Uw - (1-(this.height-this.displacement)./(Zw-this.displacement))./...
    log((this.ref_height-this.displacement)./this.roughness);
this.UAdj = Uh .* exp(this.wind_atten .* ((this.roughness+this.displacement)./this.height - 1));
this.RAero(erroneousHeight)=NaN;
this.UAdj(erroneousHeight)=NaN;
%% adjust wind speed
hasWind=wind>0;
this.UAdj=this.UAdj.*wind;
this.RAero(hasWind)=this.RAero(hasWind)./wind(hasWind);
this.RAero(~hasWind)=HUGE_RESIST;
end