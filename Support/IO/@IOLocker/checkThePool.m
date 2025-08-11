function [coreList,isMin]=checkThePool(this)
%% outputs
% coreList: index-list of local cores
% isMin: if this core is of the minimal index
%% create a thread in pool
fid=fopen([this.comNodeFolder,num2str(this.coreID),'.pool'],'w');
fclose(fid);
%% notify the monitor that th core has started
fid=fopen([this.comFolder,'IO_mat_thread_',num2str(this.coreID),'.started'],'w');
fclose(fid);
%% get the number of in use
list0=[];
count=0;
while count<10
    list=dir([this.comNodeFolder,'*.pool']);
    if length(list0)==length(list) && (~isempty(list))
        count=count+1;
    end
    list0=list;
    pause(2);
end
coreList=nan(length(list),1);
for i=1:length(list)
    strFileName=list(i).name;
    coreList(i)=str2double(strFileName(1:end-5));
end
if min(coreList)==this.coreID
    isMin=true;
else
    isMin=false;
end
end