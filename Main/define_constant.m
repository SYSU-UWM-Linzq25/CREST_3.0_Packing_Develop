function define_constant()
global m2mm
m2mm=1000;
global KELVIN T_LAPSE SECONDS_PER_DAY SECONDS_PER_HOUR
KELVIN=273.15;
T_LAPSE=-0.0065;  % temperature lapse rate of US Std Atmos in C/km */
SECONDS_PER_DAY=86400;
SECONDS_PER_HOUR=3600;
global STEFAN PS_PM CP_PM
%%%
% $$\sigma= 5.670373(21)*10^{-8}W m^{-2} K^{-4}$$
STEFAN=5.6696e-8;% STEFAN_BOLTZMAN constant, slightly different than online
PS_PM=101300;    %sea level air pressure in Pa
CP_PM=1013; %specific heat of moist air at constant pressure (J/kg/C)
% define constants for saturated vapor pressure curve (kPa) 
global A_SVP B_SVP C_SVP
A_SVP=0.61078;
B_SVP=17.269;
C_SVP=237.3;
% infinity aerodynamic resistence
global HUGE_RESIST
HUGE_RESIST=1e20;
global EPS RHO_W Ls0 Ls1 Lf CH_ICE CH_WATER Lv0 Lv1
EPS=0.628;%0.62196351; % Ratio of molecular weights: M_water_vapor/M_dry_air 
RHO_W=999.842594; % Density of water (kg/m^3) 
Ls0=677; %Cal/g,latent heat of sublimation at 0C
Ls1=-0.07;%Cal/(g*C),slope of temperature to adjust the latent heat of sublimation at a given temperature 
Lv0=2.501e6;%J/(m^3) latent heat of evaporation at 0C
Lv1=-0.002361e6;%J/(m^3*C) slope of temperature to adjust the latent heat of evaporation at a given temperature 
Lf=3.337e5;	% Latent heat of freezing (J/kg) at 0C
CH_ICE=2100.0e3;	% Volumetric heat capacity (J/(m3*C)) of ice (ice is measured by SQW)
CH_WATER=4186.8e3;  % volumetric heat capacity of water
global JOULESPCAL GRAMSPKG
JOULESPCAL=4.1868; % Joules per calorie 
GRAMSPKG=1000;%convert grams to kilograms
global RSMAX CLOSURE VPDMINFACTOR % constants for canopy resistance
RSMAX=5000; %Maximum allowable resistance (s/m)
CLOSURE=4000; %Threshold vapor pressure deficit for stomatal closure (Pa)
VPDMINFACTOR=0.1; %Minimum allowable vapor pressure deficit factor
%% canopy constants
global LAI_SNOW_MULTIPLIER MIN_SWQ_EB_THRES SMALL LAI_WATER_FACTOR DRY
LAI_SNOW_MULTIPLIER=0.5; % multiplier to calculate the amount of available snow interception as a function of LAI (m)
MIN_SWQ_EB_THRES=1;%(mm)
SMALL=1e-8;
DRY=1e-2;
LAI_WATER_FACTOR=0.1;
global K0Snow TraceSnow 
K0Snow=2.9302e-6;
TraceSnow=0.03; %the minimum amount of new snow (mm) which will reset the snowpack albedo to new snow
global Von_K g
Von_K=0.4;
g=9.81;
%% snow albedo constants
global NEW_SNOW_ALB SNOW_ALB_ACCUM_A SNOW_ALB_ACCUM_B SNOW_ALB_THAW_A SNOW_ALB_THAW_B
NEW_SNOW_ALB=0.85;
SNOW_ALB_ACCUM_A=0.94;
SNOW_ALB_ACCUM_B=0.58;
SNOW_ALB_THAW_A=0.82;
SNOW_ALB_THAW_B	=0.46;
%% snow pack constants
global LIQUID_WATER_CAPACITY MAX_SURFACE_SWQ
LIQUID_WATER_CAPACITY=0.035;% liquid water holding capacity of ice
MAX_SURFACE_SWQ=125;%(mm) maximum depth of the surface layer in water equivalent
global Ki Kw Kdry_org Ks_org
Ki = 2.2;      % thermal conductivity of ice (W/mK)
Kw = 0.57;    % thermal conductivity of water (W/mK)
Kdry_org = 0.05; % Dry thermal conductivity of organic fraction (W/mK) (Farouki 1981)
Ks_org = 0.25; % thermal conductivity of organic fraction of solid (W/mK) (Farouki 1981)
global BARE_SOIL_ALBEDO
BARE_SOIL_ALBEDO=0.2;

%% lake constants
global LAKE_DEPTH
LAKE_DEPTH=10000; %mm
end