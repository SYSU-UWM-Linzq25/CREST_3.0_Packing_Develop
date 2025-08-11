function writeProg(this,evNum,x,f,criter)
%% write a status file to store the progress information after finishing each evolution
% evNum: currently finished number of evolution. 0 Indicates the initial
% population has been simulated
fileName=this.getProgressFileName();
fid=fopen(fileName,'w');
fprintf(fid,'Evolution: %d\n',evNum);
%% record the best f values
if evNum>=1
    fmt='BestF: ';
    fmt=[fmt,repmat('%f, ',[1,evNum-1]),'%f\n'];
    fprintf(fid,fmt,criter);
end
%% record the current population of all complexes
[~,nPars]=size(x);
fmt=[repmat('%8.6f,',1,nPars),'%8.6f\n'];
fprintf(fid,fmt,[f,x]');
fclose(fid);
end
