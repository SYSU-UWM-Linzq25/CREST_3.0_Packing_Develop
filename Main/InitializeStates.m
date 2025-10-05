function InitializeStates(canopy,Tair)
canopy.Tfoliage= Tair;% + soil_con->Tfactor in VIC the resolution is coarse so that the band elevation difference within a grid is considered
% in CREST, one cell has only one elevation
end