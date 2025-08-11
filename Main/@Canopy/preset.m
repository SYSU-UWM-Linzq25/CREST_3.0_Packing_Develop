function preset(this,forcingVar,isOverstory)
Tair=forcingVar.Tair(forcingVar.basinMask);
this.TSurf(:)=Tair(isOverstory);
this.W(:)=0;
this.intSnow(:)=0;
this.TWThru(:)=NaN;
this.TThruSnow(:)=NaN;
end