function [row,col]=GetStreamRowAndCol(obj)
[rows,columns]=size(obj.DEM);
[C,R]=meshgrid(1:columns,1:rows);
row=R(obj.stream);
col=C(obj.stream);
end