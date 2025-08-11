function energy_balances(isOverstory,atten_canopy,Wm,...
                         shortRad,snowfall,rainfall,windCanopy,LAI,...
                         TfoliageOld,intSnowOrg,intRainOrg,snowpackSWEOrg)
%% Algorithm Description
% 
% <<E:\Dropbox\code\MFiles\CREST_3\energy_balances\framework.PNG>>
% 

%% output 
%% input
% isOverstory: whether a canopy layer exists
% atten_canopy: the attenuation by the canopy layer. The value is 1 at bare surfaces
% shortRad: incoming short wave radiation
%% compute the canopy interception of vegetated cells
[intSnowOS,intRainOS,snowThruOS,rainThruOS]=canopy_interception(LAI(isOverstory),snowfall(isOverstory),rainfall(isOverstory),windCanopy,...
                             TfoliageOld(isOverstory),intSnowOrg(isOverstory),intRainOrg(isOverstory),Wm(isOverstory));
%% partition the energy of incidence
surf_atten(~isOverstory)=1;
isSnow=(intSnowOrg+intRainOrg+snowpackSWEOrg)>0;
surf_atten((~isSnow)&isOverstory)=0;
shortUnderIn = surf_atten.*shortRad;  % SW transmitted to the ground
ShortOverIn  = shortwave-shortUnderIn; % SW incident to the canopy
end