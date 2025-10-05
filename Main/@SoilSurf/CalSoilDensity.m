function CalSoilDensity(this)
%% algorithm description
% Wm=depth*porosity*m2mm;
% porosity = 1.0 - this.bulk_density./ this.soil_density;
global m2mm
this.soil_density=zeros(this.nCells,this.nLayers);
for iL=1:this.nLayers
    porosity=this.Wm(:,iL)/m2mm./this.depths(iL);
    this.soil_density(:,iL)=this.bulk_density(:,iL)./(1-porosity);
end
end