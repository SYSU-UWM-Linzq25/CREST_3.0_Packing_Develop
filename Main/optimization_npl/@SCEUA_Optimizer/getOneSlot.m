function [freeSlot,resGen]=getOneSlot(this,isEV)
%% Algorithm Description
% this function repeatedy request a free slot
%% output
% freeSlot: the free Core#
% resGen: whether the core is released from a previous simulation
%return a freeSlots index otherwise return -1
freeSlot=find(this.lsWorkers==-1,1,'first');
resGen=false;
while isempty(freeSlot)
    for ic=1:this.nParal
        if isEV
            fileSimRes=[this.comFolder,this.fileNameHead,num2str(ic) '.evres'];
        else
            fileSimRes=[this.comFolder,this.fileNameHead,num2str(ic) '.res'];
        end
         if exist(fileSimRes,'file')==2
            freeSlot=ic;
            resGen=true;
            break;
         end
    end
    pause(0.01);
end
if resGen
    disp(['found a free slot from previous occupation: core',num2str(freeSlot)])
else
    disp(['found a free slot: core', num2str(freeSlot)]);
end
end