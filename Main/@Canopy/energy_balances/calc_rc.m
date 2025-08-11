function rc=calc_rc(r0c,RGL,...
            net_short,Tair,VPD,LAI,...
            gsm_inv,bRefCrop)
%% calculate canopy resistance of maximum vegetation transpiration rate
% Canopy resistance is used in equation (5) of (Liang 1994) and is computed
% in the following two ways
%% input variables
% r0c:minimum stomotal resistance
% RGL: Value of solar radiation below which will be no transpiration (ranges from 
    %~30 W/m^2 for trees to ~100 W/m^2 for crops)
% net_short:net short radiation
% Tair: air temperature
% VPD: vapor pressure deficit
%
% $$ gsm_inv : 1/g_sm
%
% bRefCrop: 1|0=complex way| simple way
%% output variable
% rc: canopy resistance
global RSMAX CLOSURE VPDMINFACTOR
nCells=length(r0c);
rc=zeros(nCells,1);
indexZeroLAI=LAI==0;
indexZeroResist=r0c==0;
rc(indexZeroLAI&(~indexZeroResist))=RSMAX;% set the canopy resistance to its uplimit where LAI=0 and there is a minimal resistance
indexToBeCalculated=~(indexZeroLAI|indexZeroResist);
if bRefCrop
    %% the simple way:
    % $$ rc=r_{0c}g_{sm}/LAI $$
    rc(indexToBeCalculated)=r0c(indexToBeCalculated)./(LAI(indexToBeCalculated) * 0.5);
else
    %% the complex way
    frac = net_short(indexToBeCalculated) ./ RGL(indexToBeCalculated);
    dayFactor = (1 + frac)./(frac + r0c(indexToBeCalculated)/RSMAX);
    %%% $$ g_{T} $$
    % is the temperature factor
    Tfactor = .08 * Tair(indexToBeCalculated) - 0.0016 * Tair(indexToBeCalculated).^2;
    Tfactor(Tfactor <= 0.0) = 1e-10;
    %%%
    % $$ g_{VPD} $$ 
    % is the vapor pressure deficit factor
    vpdfactor = 1 - VPD(indexToBeCalculated)/CLOSURE;
    vpdfactor(vpdfactor < VPDMINFACTOR)=VPDMINFACTOR;
     %%% $$ rc=r_{0c}g_{sm}g_{T}g_{VPD}/LAI $$
     % $$ g_{sm} $$
     % is the soil moisture stress factor depending on the water
     % availability
    rc(indexToBeCalculated) = r0c(indexToBeCalculated)./(LAI(indexToBeCalculated).* gsm_inv(indexToBeCalculated).*...
        Tfactor.*vpdfactor) .* dayFactor;
end
rc(rc > RSMAX)=RSMAX;
end