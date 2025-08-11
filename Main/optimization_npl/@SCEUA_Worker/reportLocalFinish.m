function reportLocalFinish(this)
%% notify the leading core the worker has finished
fid=fopen([this.comNodeFolder,num2str(this.coreID),'.finished'],'w');
fclose(fid);
end