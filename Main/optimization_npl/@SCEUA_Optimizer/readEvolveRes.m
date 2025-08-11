function [icf,icx]=readEvolveRes(obj,slot,nspl)
fileRes=obj.genResName(slot,true);
parnum=length(obj.keywordsAct);
fid = fopen(fileRes);
A=textscan(fid,repmat('%f',[1,nspl]),1,'Delimiter',',');
icf=cell2mat(A);
A=textscan(fid,repmat('%f',[1,parnum]),nspl,'Delimiter',',');
icx=cell2mat(A);
fclose(fid);
delete(fileRes);
%% output to screen
for i=1:size(icf,1)
    disp([num2str(icf(i,:)),',',num2str(icx(i,:))]);
end
end