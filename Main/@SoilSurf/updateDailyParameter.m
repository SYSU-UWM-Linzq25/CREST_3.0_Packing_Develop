function updateDailyParameter(this,LAI)
    global LAI_WATER_FACTOR
    this.WmVeg=LAI*LAI_WATER_FACTOR;
    this.WmVeg(this.isBare|this.isOverstory)=0;
end