function energyPhaseChange=EnergyByPhaseChange(dt,error,T,water,ice,vaporFluxSub,vaporFluxEvap)
%% compute the energy released or absorbed due to the refreezing or melting process
%% output
% energyPhaseChange J/m^2/s: positive, energyPhaseChange indicates refreezing process | negative indicates melting process
%% input
% dt (s) :time interval
% error: energy budget without accouting for the phase change
% T (C): current temperature
% water (mm): stored liquid water
% ice (mm) : swq of the snow
% vaporMassFlux (mm/s): sublimated swq of snow
% vaporFluxEvap (mm/s): evaporated liquid water only from this layer
global m2mm Lf RHO_W
% refreezing & melting Energy processes
% refreezing and melting capacities, the maximum refreeze Energy that CAN BE used to balance the energy budget
% refreezeEnergy(~hasIntSnow)=0;
refreezeCap= (water+vaporFluxEvap*dt)/m2mm*Lf*RHO_W/dt;
% the maximum melting energy that CAN BE used to balance the energy budget
meltCap=-(ice+vaporFluxSub*dt)/m2mm*Lf*RHO_W/dt;%CREST update, sublimated snow should be subtracted
% For cells with intercepted snow and the temperature of foliage (intercepted snow) is below zero,
% all intercepted rain must be frozen
bNegtiveBudget=error<0;
bZeroTemp=T==0;
bPosTemp=T>0;
bNegTemp=T<0;
%% energy due to phase change
% if the temperature is negative, all water must be refrozen
nCells=length(error);
energyPhaseChange=zeros(nCells,1);
energyPhaseChange(bNegTemp)=refreezeCap(bNegTemp);
% if the temperature is postive, all ice must melt
energyPhaseChange(bPosTemp)=meltCap(bPosTemp);
% if the tempreature is zero, the amount & direction of the phase change helps balance the budget, i.e., 
    % when energy budget(error) is negative, refreezing process occurs, otherwise,
bCompensate=bZeroTemp&bNegtiveBudget;
energyPhaseChange(bCompensate)=min(-error(bCompensate),refreezeCap(bCompensate));
    % when error is postive, melting process occurs.
bConsume=bZeroTemp&(~bNegtiveBudget);
energyPhaseChange(bConsume)=max(-error(bConsume),meltCap(bConsume));
end