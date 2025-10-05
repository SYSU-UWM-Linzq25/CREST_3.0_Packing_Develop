function n=diff2Out2grid(this,diffVal,isDist)
%% convert from difference (elevation/hydrological distance) to grid
% The difference is meausred from the subbasin outlet to the parent basin
% outlet. It only deals with temporary grids
if isDist
    n=round(diffVal/this.resD);
else
    n=round(diffVal/this.resE);
end
end