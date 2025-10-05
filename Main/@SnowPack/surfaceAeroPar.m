function surfaceAeroPar(this,wind_h)
this.displacement(:)=0;% this is suspicious
% this.displacement(~this.hasSnow)=NaN;
this.ref_height=wind_h;
this.ref_height=this.ref_height+(this.displacement+this.roughness).*...
    (this.ref_height<this.displacement);
% this.ref_height(~this.hasSnow)=NaN;
% this.roughness(~this.hasSnow)=NaN;
% this.adj_ref_height(this.hasSnow)=this.roughness(this.hasSnow)+2;
this.adj_ref_height=this.roughness+2;
% this.adj_ref_height(~this.hasSnow)=NaN;
this.adj_displacement(:)=0;
% this.adj_displacement(~this.hasSnow)=NaN;
end