function dist=col2dist(this,col)
%% covert grids to hydrological distance  
% This function only converts temporal grids
dist=(col-1)*this.resD;
end