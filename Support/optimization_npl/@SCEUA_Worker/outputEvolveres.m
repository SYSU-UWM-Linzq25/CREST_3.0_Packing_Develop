function outputEvolveres(this,cf,cx,nspl)
%create a unique result(NCSE) file in the communication file system
fid=fopen(this.fileevRes,'w');
fprintf(fid,'%8.6f, ',cf(1:end-1));
fprintf(fid,'%8.6f\n ',cf(end));
for i=1:nspl
    fprintf(fid,'%8.6f, ',cx(i,1:end-1));
    fprintf(fid,'%8.6f\n',cx(i,end));
end
fclose(fid);
disp(['Core ', num2str(this.coreID), 'finished an evolution of a group']);
end