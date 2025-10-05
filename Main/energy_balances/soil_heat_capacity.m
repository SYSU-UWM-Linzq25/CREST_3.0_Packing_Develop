function Cs=soil_heat_capacity(soil_fract,water_fract,ice_fract,organic_fract)
%% Algorithm Description
% This subroutine calculates the soil volumetric heat capacity based 
%  on the fractional volume of its component parts.
%
%  Constant values are volumetric heat capacities in J/m^3/K
%% input
% soil_fract    fraction of soil volume composed of solid soil (fract)
% organic_fract fraction of solid soil volume composed of organic matter (fract)
% water_fract   fraction of soil volume composed of liquid water (fract)
% double ice_fract     fraction of soil volume composed of ice (fract)
%% output
%  Cs: volumetric heat capacity
%% main routine
Cs  = 2.0e6 * soil_fract.*(1-organic_fract);
Cs =Cs+ 2.7e6 * soil_fract.*organic_fract;
Cs =Cs+ 4.2e6 * water_fract;
Cs =Cs+ 1.9e6 * ice_fract;
Cs =Cs+ 1.3e3 * (1. - (soil_fract + water_fract + ice_fract));
end