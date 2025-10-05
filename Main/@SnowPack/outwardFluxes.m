function [RaC,sensibleHeat,longPackOut,shortReflected,shortBareIn,netShort]=...
    outwardFluxes(nCells,hasSnow,roughness,adj_displacement,adj_ref_height,...
              UAdj,RAero,albedo,...
              TSurfTemp,TAirTemp,...
              airDens,shortUnderIn)
global KELVIN STEFAN HUGE_RESIST CP_PM
TTempInK = TSurfTemp(hasSnow) + KELVIN;
%%% Stefam-Boltzmann law for blackbody
% total energy radiated per unit surface area of a black body across all wavelengths per unit time
%
% $j^{\star} = \sigma T^{4}$
% longPackOut=zeros(this.nCells,1);
longPackOut=zeros(nCells,1);
longPackOut(hasSnow) = STEFAN * TTempInK.^4;
% longPackOut(~this.hasSnow)=0;
% this term can be ignored in practice
% groundFlux= K0Snow * this.density(this.hasSnow).^2.*(TGrnd - this.TSurf(this.hasSnow))./ this.depth(this.hasSnow) / dt;
% hasWind=UAdj>0;
% the aerodyanmic resistence of snow pack is only used for sensible heat
% the latent heat and sensible heat is computed at the 2m above the snow pack
% note that the latent heat of vegetation is not computed in this layer
[correction,noWind]=SnowPack.StabilityCorrection(sum(hasSnow),...
    UAdj(hasSnow),roughness(hasSnow),adj_displacement(hasSnow),adj_ref_height(hasSnow),...
                                    TSurfTemp(hasSnow),TAirTemp(hasSnow));
RaC=nan(nCells,1);
if ~isempty(correction)
    RaC(hasSnow)=(RAero(hasSnow)./correction).*(~noWind)+HUGE_RESIST*(noWind);
end
sensibleHeat=zeros(nCells,1);
sensibleHeat(hasSnow) = CP_PM*airDens(hasSnow).* (TAirTemp(hasSnow) - TSurfTemp(hasSnow)) ./ RaC(hasSnow);
%% reflected shortwave from the snow pack surface
shortReflected=zeros(nCells,1);
shortReflected(hasSnow)=shortUnderIn(hasSnow).*albedo(hasSnow);
%% penetrated short wave through the snow pack layer
shortBareIn=shortUnderIn;
shortBareIn(hasSnow)=0;
%% net short radiation imposed to the snow pack layer
netShort=shortUnderIn-shortReflected-shortBareIn;
end