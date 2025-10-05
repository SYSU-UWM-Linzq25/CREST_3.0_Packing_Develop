function updateAlbedo(this,dt,new_snow)
%% Algorithm description update the albedo of the surface snow pack
% Original version computed albedo as a function of snow age and season, based on the algorithm
% of the US Army Corps of Engineers.  More recently, added the option to
% use the algorithm of Sun et al., 1999, which depends only on snow age and
% cold content (independent of time of year).
%% input
% dt: how many hours a time step
% new_snow:
%% main routing
global NEW_SNOW_ALB TraceSnow SNOW_ALB_ACCUM_A SNOW_ALB_ACCUM_B SNOW_ALB_THAW_A SNOW_ALB_THAW_B BARE_SOIL_ALBEDO
%% no snow
noSnow=(new_snow==0)&(this.swqTotal==0);
this.albedo(noSnow)=NaN;
%% initialize all cells with snow the albedo of the soil (in case some are new thin snow, which does not fall into the cases below) 
this.albedo(new_snow>0|this.swqTotal>0)=BARE_SOIL_ALBEDO;
%% New Snow
isNewThick=new_snow > TraceSnow;
this.albedo(isNewThick)= NEW_SNOW_ALB;
isThinSnow=(~isNewThick)&(this.swqTotal>0);
isAccumulating=isThinSnow&(~this.melting)&(this.CCSurf<0);
isMelting=isThinSnow&(this.melting|this.CCSurf>=0);
%% Aged Snow
% Accumulation season
this.albedo(isAccumulating)=NEW_SNOW_ALB*SNOW_ALB_ACCUM_A.^((this.last_snow(isAccumulating) * dt / 24).^SNOW_ALB_ACCUM_B);
% melting season
this.albedo(isMelting)=NEW_SNOW_ALB*SNOW_ALB_THAW_A.^((this.last_snow(isMelting) * dt / 24).^SNOW_ALB_THAW_B);
end