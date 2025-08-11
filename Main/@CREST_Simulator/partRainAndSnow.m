function partRainAndSnow(this,Tair,prec,MIN_RAIN_TEMP,MAX_SNOW_TEMP)
this.rain(:)=0;
if MAX_SNOW_TEMP==MIN_RAIN_TEMP && MIN_RAIN_TEMP~=0
    warning('ice temperature not zero');
end
if MIN_RAIN_TEMP>MAX_SNOW_TEMP
    error('minimal temperature of rain is larger than maximal temperature of snow');
end
isCold=Tair<MIN_RAIN_TEMP;
isWarm=Tair>MAX_SNOW_TEMP;
isBetween=~(isCold|isWarm);
if MAX_SNOW_TEMP>MIN_RAIN_TEMP
    this.rain(isBetween) = (Tair(isBetween) - MIN_RAIN_TEMP)/(MAX_SNOW_TEMP - MIN_RAIN_TEMP) .* prec(isBetween);
end
this.rain(isWarm)=prec(isWarm);
% this.rain=prec;% temp
this.snow=prec-this.rain;

end