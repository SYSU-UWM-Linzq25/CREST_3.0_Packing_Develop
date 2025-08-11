function raster=SetNull(raster,NoData)
raster(raster==NoData)=NaN;
end