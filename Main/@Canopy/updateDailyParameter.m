function updateDailyParameter(this,LAI)
global LAI_WATER_FACTOR
if isempty(LAI)
    LAI=zeros(size(this.rad_atten));
end
this.Wm=LAI*LAI_WATER_FACTOR;
this.short_atten=exp(-this.rad_atten.*LAI);
end