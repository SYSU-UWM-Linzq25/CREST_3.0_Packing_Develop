function [svp,svpGrad]=saturatedVaporPressure(T)
%% calculates the saturated vapour pressure at the given air temperature
% by Shen, Xinyi, April, 2015
% contact xinyi.shen@uconn.edu
%% references
%% output
% svp (Pa): saturated vapor pressure 
% svpGrad (Pa/K): the slope of saturated vapor pressure 
%% input 
% $$ T (in~^oC)$ 
% :mean air temperature during a time step
global A_SVP B_SVP C_SVP
svp=A_SVP * exp((B_SVP * T)./(C_SVP+T))*1000;
indexFrozen=T<0;
svp(indexFrozen)=svp(indexFrozen).*...
    (1.0+.00972*T(indexFrozen)+.000042*T(indexFrozen).^2);
if nargout>1
    svpGrad=(B_SVP * C_SVP)./(C_SVP + T).^2.*svp;
end
end