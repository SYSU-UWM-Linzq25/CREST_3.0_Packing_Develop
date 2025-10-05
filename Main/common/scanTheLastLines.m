function C=scanTheLastLines(fileName,fmt,nLines,delimiter)
if ispc
    disp('platform not supported');
    totalLines=nLines;
else
    [~,cmdout] = system(['wc -l<',fileName]);
    totalLines=str2num(cmdout);
end
nSkipLines=totalLines-nLines;
fid=fopen(fileName);
if nSkipLines>0
    textscan(fid,fmt,nSkipLines,'Delimiter',delimiter);
end
C=textscan(fid,fmt,'Delimiter',delimiter);
fclose(fid);
end