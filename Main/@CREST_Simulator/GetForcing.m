function GetForcing(this)
global prec_adj
%% partition snow/rain from precipitation
this.partRainAndSnow(this.forcingVar.Tair(this.forcingVar.basinMask),...
   this.forcingVar.prec(this.forcingVar.basinMask),...
   this.forcingVar.MIN_RAIN_TEMP,this.forcingVar.MAX_SNOW_TEMP);
this.rain=this.rain* this.globalVar.timeStepInMLS;
this.snow=this.snow* this.globalVar.timeStepInMLS;
if prec_adj
    this.NLDASAdj();
end
%% other forcing variables
this.shortwave=this.forcingVar.shortwave(this.forcingVar.basinMask);
this.longwave=this.forcingVar.longwave(this.forcingVar.basinMask);
this.pressure=this.forcingVar.pres(this.forcingVar.basinMask);
this.LAI=this.forcingVar.LAI(this.forcingVar.basinMask);
this.Tair=this.forcingVar.Tair(this.forcingVar.basinMask);
this.wind=this.forcingVar.wind(this.forcingVar.basinMask);
%% compute actual vapor pressure
this.calVP();
end