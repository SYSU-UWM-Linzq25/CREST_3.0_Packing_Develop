function checkLocStartPerm(this)
while exist([this.comNodeFolder 'clean.completed'],'file')~=2
    pause(2);
end
disp('obtained start permission. starting the operation');
% %% notify the leading core that the worker has started
fid=fopen([this.comNodeFolder,num2str(this.coreID),'.started'],'w');
fclose(fid);
end