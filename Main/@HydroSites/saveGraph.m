function saveGraph(this,fileHydro,dateCur)
dim=ones(1,length(this.meanSimGVar{1}));
Var=cell(1,2*length(this.meanSimGVar{1}));
Var(1:2:end-1)=mat2cell(this.meanSimGVar{1},dim);
Var(2:2:end)=mat2cell(this.GVar{1},dim);
dstr=datestr(dateCur,this.datefmtInt{1});
if ~this.started
    title=cell(1,2*length(this.GVar{1})+1);
    title{1}='Date';
    for it=1:length(this.GVar{1})
        title{2*it}=['ET_' num2str(it)];
        title{2*it+1}=['ET_Obs_' num2str(it)];
    end
    content=table(cellstr(dstr),Var{:},'VariableNames',title);
    writetable(content,fileHydro,'Delimiter',',');
    this.started=true;
else
    dtn=str2double(dstr);
    dlmwrite(fileHydro,{dtn,Var{:}},'delimiter',',','precision',8,'-append');
end
end