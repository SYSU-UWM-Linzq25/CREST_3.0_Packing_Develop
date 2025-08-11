function [xTemp,keywords]=readpar(this)
%after checking parameter file  read
fid=fopen(this.filePar);
A=fgetl(fid);
keywords=strsplit(A,',');
keywords=strtrim(keywords);
A=textscan(fid,'%f','Delimiter',',');
%formatlong
xTemp=A{:};
disp(['Core #',num2str(this.coreID),' gained', num2str(length(xTemp)),  'long parameter file']);
%disp(xTemp);
fclose(fid);
end