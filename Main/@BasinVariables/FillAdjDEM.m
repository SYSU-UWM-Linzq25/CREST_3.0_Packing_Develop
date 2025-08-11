function z_adj=FillAdjDEM(obj,r_adj,c_adj,r,c)
% (r_adj,c_adj): the (row, col) of one of the 8-adjacent cell
% (r,c)        : the (row, col) of the center cell
% (rows,columns): number of the rows and columns of basic data
index=obj.InRectangle(r_adj,c_adj);
z_adj=zeros(size(index));
z_adj(index)=obj.DEM(sub2ind(size(obj.DEM),r_adj(index),c_adj(index)));
z_adj(~index)=obj.DEM(sub2ind(size(obj.DEM),r(~index),c(~index)));
% for the adj cells out of the basin the DEM value of the center cell is used
% it is impossible for the DEM value of centric cell being NoData
indexNoData=isnan(z_adj);
z_adj(indexNoData)=obj.DEM(sub2ind(size(obj.DEM),r(indexNoData),c(indexNoData)));
end