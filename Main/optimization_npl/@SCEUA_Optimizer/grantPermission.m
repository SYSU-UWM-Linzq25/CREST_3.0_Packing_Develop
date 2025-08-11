function  grantPermission(obj,core,i,xTemp)
%% submit a task
% core: the idle core # to work
% i: the index of the temporary parameter-set in the current population
% xTemp: the value of the parameter-set
parFileName=obj.genParName(core,false);
parFileName1=parFileName;
parFileName1(end-2:end)='nfn';
fid=fopen(parFileName1,'w');
fprintf(fid,'%s, ',obj.keywordsAct{1:end-1});
fprintf(fid,'%s\n',obj.keywordsAct{end});
fprintf(fid,'%8.6f, ',xTemp(1:end-1));
fprintf(fid,'%8.6f\n ',xTemp(end));
fclose(fid);
movefile(parFileName1,parFileName,'f');
disp(['Parameter ' num2str(i) ' is submitted to core ' num2str(core)]);
obj.lsWorkers(core)=i;
end