function GetBasinMask(obj)
    [rows,cols]=size(obj.DEM);
    obj.basinMask=zeros(rows,cols);
    obj.basinMask(isnan(obj.DEM))=0;
    obj.basinMask(~isnan(obj.DEM))=1;
    obj.basinMask=logical(obj.basinMask);
end