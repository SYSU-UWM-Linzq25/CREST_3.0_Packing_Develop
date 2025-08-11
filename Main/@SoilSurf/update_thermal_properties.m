function update_thermal_properties(this)
%% in version 3.0, only the temperature in the two layers are differnt, soil moisture and thermal properties are the same
global m2mm
Depth=repmat(this.depths(:)',[this.nCells,1]);
moist=this.W./Depth/m2mm;
Ice=this.ice./Depth/m2mm;
liquid=moist - Ice;
for l=1:this.nLayers
    this.kappa(:,l) = soil_conductivity(moist(:,l), liquid(:,l),... 
         this.soil_dens_min(:,l), this.bulk_dens_min(:,l), this.quartz(:,l),...
	     this.soil_density(:,l), this.bulk_density(:,l), this.organic(:,l));
    this.Cs(:,l) = soil_heat_capacity(...
         this.bulk_density(:,l)./this.soil_density(:,l), liquid(:,l), Ice(:,l), this.organic(:,l));
end
end