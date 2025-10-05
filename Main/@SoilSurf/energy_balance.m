function error=energy_balance(nCells,hasSnow,isOverstory,...
    TSurfTemp,T1Temp,dt,sensibleHeat,latentHeat,netBareRad,errorCanopy,optSoilThermal,...
    D1,D2,dp,...
    Cs,TSurf,T1)
%% Algorithm Description
% all cells must be calculated
% note that this function must be called after the canopy balance
%% input
% TSurfTemp
% dt (s): model time step
% netShortUnder (W/m^2):net short radiation to understory after canopy
% attenuation and reflection of the surface
% sensibleHeat(W/m^2): Sensible heat exchange between the top boundary of surface soil layer (from the top layer to the soil)
% latentHeat(-W/m^2): latent heat by ET of the vegetation in cells with no canopy (latent heat of canopy is set zero)
% errorCanopy(W/m^2) residual energy budget of the canopy. The dimension is the number of cells with a canopy layer
    % note that cells without intsnow have 0 value of errorCanopy

%% heat storage change
% linear temperature profile in the surface layer is assumed
if strcmp(optSoilThermal,'Countinuous_Neumann')
    C1=Cs(:,1)*D1/(2*dt);
    dHeat=C1.*(TSurfTemp-TSurf)+(C1+Cs(:,2)*dp/dt.*(1-exp(-D2/dp))).*(T1Temp-T1);
else
    dHeat=Cs(:,1).*((TSurfTemp+T1Temp)-(TSurf+T1))*D1/dt/2;
end
latentHeat(hasSnow)=0;
%% balance
error = netBareRad+ sensibleHeat+ latentHeat- dHeat;
% the energy budget of canopy without snow interception must be added to
% either the snowpack energy balance where there is snow pack or the soil surface where there is no snowpack 
errorCanopyAll=zeros(nCells,1);
errorCanopyAll(isOverstory)=errorCanopy;
errorCanopyAll(hasSnow)=0;
error=error+errorCanopyAll;
end