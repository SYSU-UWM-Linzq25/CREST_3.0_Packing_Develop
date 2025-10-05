function finalizeEvolve(obj,ic)
%% notify the worker the work has finished
[directory,name,ext]=fileparts(obj.fileExit);
fileExistCore=[directory,name,num2str(ic),ext];
fid=fopen(fileExistCore,'w');
fclose(fid);
end
