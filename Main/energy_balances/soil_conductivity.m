function K=soil_conductivity(moist,Wu,...
             soil_dens_min,bulk_dens_min,quartz,...
			 soil_density,bulk_density,organic)
%% Algorithm Description
% Soil thermal conductivity calculated using Johansen's method.
% Reference: Farouki, O.T., "Thermal Properties of Soils" 1986
%	Chapter 7: Methods for Calculating the Thermal Conductivity 
%		of Soils
%
%  H.B.H. - refers to the handbook of hydrology.
%  porosity = n = porosity
%  ratio = Sr = fractionaldegree of saturation
%  All K values are conductivity in W/mK
% Wu is the fractional volume of unfrozen water
%  UNITS: input in m, kg, s
%% output
% K in W/m/K
%% input
% moist         total moisture content (mm/mm)
% Wu            liquid water content (mm/mm)
% soil_dens_min mineral soil particle density (kg m-3)
% bulk_dens_min mineral soil bulk density (kg m-3)
% quartz        mineral soil quartz content (fraction of mineral soil volume)
% soil_density  soil particle density (kg m-3)
% bulk_density  soil bulk density (kg m-3)
% organic       total soil organic content (fraction of total solid soil volume)
%                         i.e., organic fraction of solid soil = organic*(1-porosity)
%                               mineral fraction of solid soil = (1-organic)*(1-porosity)
%% main routine
global Ki Kw Kdry_org Ks_org DRY
%   double Ke;
%   double Ksat;
%   double Kdry;          
%   double Ks;            /* thermal conductivity of solid (W/mK), including mineral and organic fractions */
%   double Ks_min;        /* thermal conductivity of mineral fraction of solid (W/mK) */
%   double Sr;            /* fractional degree of saturation */
%   double K;
%   double porosity;
nCells=length(moist);
K=zeros(nCells,1);
% Calculate dry conductivity as weighted average of mineral and organic fractions.
    % Dry thermal conductivity of mineral fraction (W/mK)
Kdry_min = (0.135*bulk_dens_min+64.7)./(soil_dens_min-0.947*bulk_dens_min);
% Dry thermal conductivity of soil (W/mK), including mineral and organic fractions */
Kdry = (1-organic).*Kdry_min + organic.*Kdry_org;
hasWater=moist>DRY;
K(~hasWater)=Kdry(~hasWater);
porosity = 1.0 - bulk_density./ soil_density; 
Sr = moist./porosity;
%NOTE: if excess_ice present, this is actually effective_porosity

% Compute Ks of mineral soil; here "quartz" is the fraction (quartz volume / mineral soil volume)
Ks_min = 7.7.^quartz.*(3.0.^(1.0-quartz).*(quartz<0.2)+2.2.^(1.0-quartz).*(quartz>=0.2));
Ks = (1-organic).*Ks_min + organic.*Ks_org;
unfrozen=Wu==moist;
Ksat = Ks.^(1.0-porosity) .* (Kw.^porosity.*unfrozen+Ki.^(porosity-Wu) .* Kw.^Wu.*(~unfrozen));
Ke = (0.7 * log10(Sr) + 1.0).*unfrozen+Sr.*(~unfrozen);
K(hasWater) = (Ksat(hasWater)-Kdry(hasWater)).*Ke(hasWater)+Kdry(hasWater);
K(K<Kdry)=Kdry(K<Kdry);
end