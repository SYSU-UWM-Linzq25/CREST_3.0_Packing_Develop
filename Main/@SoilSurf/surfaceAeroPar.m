function surfaceAeroPar(this,wind_h,treeHeight)
% all cells are calculated 
% the adj_ref_height
% calculated within this layer
height = this.roughness(this.isBare)/0.123;
% this.height(this.isOverstory)=treeHeight;
this.displacement(this.isBare)=2/3*height;
% this.roughness(~this.isBare)=this.roughVeg;
% this.ref_height(~this.isBare)=wind_h(~this.isBare);
% this.ref_height(~this.isBare)=this.ref_height(~this.isBare)+...
%     (this.displacement(~this.isBare)+this.roughness(~this.isBare)).*...
%     (this.ref_height(~this.isBare)<this.displacement(~this.isBare));
% this.ref_height(this.isBare)=10;% for bare soil, wind speed is measured at 10m height
this.ref_height=wind_h;
this.ref_height=this.ref_height+(this.displacement+this.roughness).*...
    (this.ref_height<this.displacement);
% for surface soil , aerodynamic variables are coverted to at 2m above the
% surface
this.adj_ref_height(:)=2;
% adjusted displacement of understory is always zero;
this.adj_displacement(:)=0;
end