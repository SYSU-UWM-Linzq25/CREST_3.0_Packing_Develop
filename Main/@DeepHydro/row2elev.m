function elev=row2elev(this,row,rowMin)
%% covert row to elevation difference
% This function only converts temporal grids
elev=(row-rowMin-1)*this.resE;
end