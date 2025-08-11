function wkt=GetGCS(shortName)
%% use this function with caution on windows, the path of GDAL needs to be preset
% cmd=['!gdalsrsinfo -o wkt "',shortName,'" >~/proj.txt'];
cmd=['! D:\Dropbox\libraries\GDAL\gdal_1110\bin\gdalsrsinfo.exe -o wkt "',shortName,'"'];
wkt=evalc(cmd);
end