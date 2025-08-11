function raster=ReplaceNull(raster,NoData)
raster(isnan(raster))=NoData;
end