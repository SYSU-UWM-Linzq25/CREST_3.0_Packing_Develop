function netRad=netRadiation(netShortOver,longOverIn,longOverOut,longUnderOut,grndFlux)
%% net long wave radiation
if isempty(netShortOver)
    netRad=[];
    return;
end
netLongOver=longOverIn + longUnderOut- 2*longOverOut;
% CREST corrected for soil surface, underOut is the ground heat flux caused by the
% temperature gradience of the surface layer and deep soil; for snowpacked
% cells, it is the outgoing longwave and snowpack reflected then attenuated by the canopy layer
% longUnderOut=longUnderOutSoil+longUnderOutSnow;
netRad = netShortOver + netLongOver-grndFlux;%CREST corrected 
end