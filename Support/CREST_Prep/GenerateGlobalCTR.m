function GenerateGlobalCTR(dir,gName,bottom,left,res,nRow,nCol,NoData,site_no,lat,lon,outlet)
timeMark='d';
timeStep=1;
startDate=19970101;
warmupDate=19970331;
endDate=20051231;
runStyle='simu';
format='asc';
basicPath='".\BASIC\"';
paramPath='".\Param\"';
statePath='".\States\"';
ICSPath='".\ICS\"';
rainPath='"C:\Data\mete data\CHINA\data\export\Rain\rain."';
PETPath='"C:\Data\mete data\CHINA\data\export\PET\pet."';
resultPath='".\Result\"';
calibPath='".\Calib\"';
OBSPath='".\OBS\"';
nSites=length(site_no);
gFile=strcat(dir,'\',gName);
fileID = fopen(gFile,'w');
fprintf(fileID,'#############################################\n');
fprintf(fileID,'# MODEL AREA\n'); 
fprintf(fileID,'#############################################\n');
fprintf(fileID,'NRows\t=\t%d\t# Number of rows\n',nRow);					
fprintf(fileID,'NCols\t=\t%d\t# Number of columns\n',nCol);
fprintf(fileID,'xllCorner\t=\t%13.10f\t# left\n',left);
fprintf(fileID,'yllCorner\t=\t%13.10f\t# top\n',bottom);	
fprintf(fileID,'CellSize\t=\t%13.10f\t# Grid resolution in degree\n',res);	
fprintf(fileID,'NODATA_value\t=\t%d\t \n',NoData);	
fprintf(fileID,'#############################################\n');
fprintf(fileID,'# MODEL Run Time Information\n'); 
fprintf(fileID,'#############################################\n');
fprintf(fileID,'TimeMark\t=\t%s\t#y(year);m(month);d(day);h(hour);u(minute);s(second)\n',timeMark);
fprintf(fileID,'TimeStep\t=\t%d\n',timeStep);	
fprintf(fileID,'StartDate\t=\t%d\n',startDate);
fprintf(fileID,'LoadState\t=\t no \n');
fprintf(fileID,'WarmupDate\t=\t%d\n',warmupDate);
fprintf(fileID,'EndDate\t=\t%d\n',endDate);
fprintf(fileID,'SaveState\t=\t no \n');
fprintf(fileID,'RunStyle\t=\t%s\t# simu, cali_SCEUA, RealTime\n',runStyle);

fprintf(fileID,'#############################################\n');
fprintf(fileID,'# MODEL Directory\n');
fprintf(fileID,'#############################################\n');
fprintf(fileID,'BasicFormat\t=\t%s\t#asc,txt,biffit, dbif\n',format);
fprintf(fileID,'BasicPath\t=\t%s\n',basicPath);
fprintf(fileID,'ParamFormat\t=\t%s\n',format);
fprintf(fileID,'ParamPath\t=\t%s\n',paramPath);
fprintf(fileID,'StateFormat\t=\t%s\n',format);
fprintf(fileID,'StatePath\t=\t%s\n',statePath);
fprintf(fileID,'ICSFormat\t=\t%s\n',format);
fprintf(fileID,'ICSPath\t=\t%s\n',ICSPath);

fprintf(fileID,'RainFormat\t=\t%s\n',format);
fprintf(fileID,'RainPath\t=\t%s\n',rainPath);
fprintf(fileID,'PETFormat\t=\t%s\n',format);
fprintf(fileID,'PETPath\t=\t%s\n',PETPath);

fprintf(fileID,'ResultFormat\t=\t%s\n',format);
fprintf(fileID,'ResultPath\t=\t%s\n',resultPath);

fprintf(fileID,'CalibFormat\t=\t%s\n',format);
fprintf(fileID,'CalibPath\t=\t%s\n',calibPath);

fprintf(fileID,'OBSFormat\t=\t%s\n',format);
fprintf(fileID,'OBSPath\t=\t%s\n',OBSPath);

fprintf(fileID,'#############################################\n');
fprintf(fileID,'# OutPix Information\n'); 
fprintf(fileID,'#############################################\n');

fprintf(fileID,'NOutPixs\t=\t%d\t# Number of pixels for which output should be produced\n',nSites);
fprintf(fileID,'OutPixColRow\t=\t no\n');
for i=1:nSites
    fprintf(fileID,'OutPixName%d\t=\t%d \n',i,site_no(i));
    fprintf(fileID,'OutPixLong%d\t=\t%13.10f\n',i,lon(i));
    fprintf(fileID,'OutPixLati%d\t=\t%13.10f\n',i,lat(i));
end

fprintf(fileID,'#############################################\n');
fprintf(fileID,'#Outlet Information\n'); 
fprintf(fileID,'#############################################\n');
fprintf(fileID,'HasOutlet\t=\t yes\n');
fprintf(fileID,'OutletColRow\t=\t no\n');
fprintf(fileID,'OutletName\t=\t no\n');
indexOutlet=site_no==outlet;
fprintf(fileID,'OutletName\t=\t%d \n',outlet);
fprintf(fileID,'OutletLong\t=\t%13.10f\n',lon(indexOutlet));
fprintf(fileID,'OutletLati\t=\t%13.10f\n',lat(indexOutlet));

fprintf(fileID,'#############################################\n');
fprintf(fileID,'#Grid Outputs\n'); 
fprintf(fileID,'#############################################\n');
fprintf(fileID,'GOVar_Rain\t=\t no\n');
fprintf(fileID,'GOVar_EPot\t=\t no\n');
fprintf(fileID,'GOVar_EAct\t=\t no\n');
fprintf(fileID,'GOVar_W\t=\t no\n');
fprintf(fileID,'GOVar_SM\t=\t no\n');
fprintf(fileID,'GOVar_R\t=\t no\n');
fprintf(fileID,'GOVar_ExcS\t=\t no\n');
fprintf(fileID,'GOVar_ExcI\t=\t no\n');
fprintf(fileID,'GOVar_RS\t=\t no\n');
fprintf(fileID,'GOVar_RI\t=\t no\n');
fprintf(fileID,'#############################################\n');
fprintf(fileID,'NumOfOutputDates\t=\t0\n');
fclose(fileID);
fclose('all')
end
