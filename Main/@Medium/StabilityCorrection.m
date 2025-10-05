function [correction,noWind]=StabilityCorrection(nCells,UAdj,roughness,adj_displacement,adj_ref_height,...
                                                 TSurfTemp,Tair)
global g KELVIN
%% output
% correction;		correction to aerodynamic resistance due to temperature
% difference between the boundary
%% input
% Z          - Reference height of the readjusted wind speed and aerodynamic (m)
%            it is 2m for understory surfaces (snowpack&soil surface, Zw for overstory)
%            note that it is not the height of windspeed measurement but
%            the adjusted height
% Tair       - Air temperature (C)
% wind       - adjusted wind speed (m/s)
%% main
% Ri;       Richardson's Number
% RiLimit;  Upper limit for Richardson's Number
RiCr = 0.2;             % Critical Richardson's Number
% Calculate the effect of the atmospheric stability using the Richardson Number approach 
% Non-neutral conditions 
hasWind=UAdj>0;
nonNeutral=TSurfTemp~=Tair;
% wind=UAdj(hasWind);
noWind=~hasWind;
bCorrected=hasWind&nonNeutral;
%% neutral cells need no correction
correction=ones(nCells,1);
% correction(~bCorrected)=1;
if ~any(bCorrected)
    return;
end
%% non-neutral cells
TairK=Tair(bCorrected)+KELVIN;
TSurfK=TSurfTemp(bCorrected)+KELVIN;

Ri = g * (TairK - TSurfK) .*(adj_ref_height(bCorrected) - adj_displacement(bCorrected))./...
    ((TairK+TSurfK)/2.0 .* (27.78*UAdj(bCorrected)).^2);
RiLimit = TairK./((TairK+TSurfK)/2.0 .* (log((adj_ref_height(bCorrected)-adj_displacement(bCorrected))./roughness(bCorrected)) + 5));
Ri(Ri>RiLimit)=RiLimit(Ri>RiLimit);
Ri(Ri<-0.5)=-0.5;
correction(bCorrected)=(1-Ri/RiCr).^2.*(Ri>0)+sqrt(1-16*Ri).*(Ri<=0);

end