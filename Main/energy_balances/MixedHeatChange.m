function deltaHeat=MixedHeatChange(Tnew,Told,depth,CH_LIQUD,CH_SOLID)
%% compute the heat storage change
% positive return indicates absorbing energy.
global m2mm
dTAboveMelting=(Tnew>=0).*Tnew-(Told>=0).*Told;
dTBelowMelting=(Tnew<=0).*Tnew-(Told<=0).*Told;
deltaHeat=depth/m2mm.*(dTBelowMelting*CH_SOLID+dTAboveMelting*CH_LIQUD);
end