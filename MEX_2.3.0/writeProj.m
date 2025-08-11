function writeProj(fileShape,proj)
[dir,shapeName,~]=fileparts(fileShape);
fileProj=[dir,'\',shapeName,'.prj'];
fid=fopen(fileProj,'w');
fprintf(fid,proj);
fclose(fid);
end