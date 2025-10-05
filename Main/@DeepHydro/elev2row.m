function row=elev2row(this,elevDiff,toSave,rowEMin)
%% discretize elevation difference to row number
% row: 1-based row number in DE grids
% hydroDist: 
% offset (in length): usually the min value of the elevation difference (can be
% negative), otherwise:0
% the grid is 1-based
if toSave
    row=round(elevDiff/this.resESave)+1;
    row(row<1)=1;
else
    row=round(elevDiff/this.resE)-rowEMin+1;
end
end
