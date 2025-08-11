GDALLoad()
for i=1:365
    fileET=['G:\mete_data\ET\CONUS\USA_dailyET_2002_' num2str(i) '.tif']
    addCS(xllcorner,yllcorner,cellsize,nRows,NoDataVal,GDT_Float,fileET,fileBasinMask);
end
