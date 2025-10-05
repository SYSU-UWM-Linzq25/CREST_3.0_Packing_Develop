function netRad=netRadiation(nCells,hasSnow,netShortPack,longUnderIn,longPackOut)
%% net long ratiation imposed to the snow pack layer
netLong=zeros(nCells,1);
netLong(hasSnow) = longUnderIn(hasSnow)-longPackOut(hasSnow);
%% net radiation 
% Note that the soil flux is not added into the net radiation of the
% surface layer of the snow pack because the soil flux comes from the
% bottom of the pack layer. Therefore, the soil flux must be delicatedly
% accounted for in the energy balance of this medium.
netRad=netShortPack+netLong;
end