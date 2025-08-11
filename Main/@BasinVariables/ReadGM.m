function ReadGM(obj,fileName)
fid=fopen(fileName);
tline = fgetl(fid);
obj.GM=str2double(tline);
tline=fgetl(fid);
obj.heightNextToOutlet=str2double(tline);
fclose(fid);
end