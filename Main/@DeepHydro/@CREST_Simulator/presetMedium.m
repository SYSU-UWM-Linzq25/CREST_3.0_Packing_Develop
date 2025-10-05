function presetMedium(this)
this.numOfNotConv=0;
this.numOfImpossibleT=0;
this.soilSurf.preset(this.stateVar,this.forcingVar);
this.snowpack.preset();
this.canopy.preset(this.forcingVar,this.soilSurf.isOverstory);
end