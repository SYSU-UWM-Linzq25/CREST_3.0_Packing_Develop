function col=dist2col(this,hydroDist,toSave)
%% discretize hydrological distance value to grids
% hydroDist: 
% offset (in length): usually the min value of the elevation difference (can be
% negative), otherwise:0
% the grid is 1-based
if toSave
    col=round(hydroDist/this.resDSave)+1;
else
    col=round(hydroDist/this.resD)+1;
end
end
