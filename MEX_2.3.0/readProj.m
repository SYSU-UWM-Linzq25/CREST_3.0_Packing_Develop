function wkt=readProj(fileProj)
fid=fopen(fileProj);
wkt=fgetl(fid);
fclose(fid);
end