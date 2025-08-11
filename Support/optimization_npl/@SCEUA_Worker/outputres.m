function outputres(this,res)
%create a unique result(NCSE) file in the communication file system
fid=fopen(this.fileRes,'w');
fprintf(fid,'%8.6f',res);
fclose(fid);
disp(['Core ', num2str(this.coreID), 'finished an simulation']);
end