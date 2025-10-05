function vaporRest=evap(this,dt,vaporFluxEvapVeg,vaporFluxGrnd,vaporFluxTrans)
global SMALL
vapor=max(-this.WVeg(~this.isOverstory),vaporFluxEvapVeg(~this.isOverstory)*dt);
vaporRest=vaporFluxEvapVeg(~this.isOverstory)*dt-vapor;
vaporRest(abs(vaporRest)<SMALL)=0;
% short veg evaporation
this.WVeg(~this.isOverstory)=this.WVeg(~this.isOverstory)+vapor;
this.WVeg(abs(this.WVeg)<SMALL)=0;
this.WThru(~this.isOverstory)=this.WThru(~this.isOverstory)+vaporRest;
this.WThru=this.WThru+vaporFluxGrnd*dt;
this.WThru(abs(this.WThru)<SMALL)=0;
% transpiration+bare soil evaporation
this.WOrg=this.W;
this.W=this.W+vaporFluxTrans*dt;
this.W(abs(this.W)<SMALL)=0;
end