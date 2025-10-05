function GetNodeBasinMask(this,fileRefMask,node,nodeNum)
%% using the index of reference to divide the basin for parallel computation
refMask=ReadRaster(fileRefMask);
indRef=refMask(this.basinMask);
this.maskEnt=this.basinMask;
indRefu=unique(indRef);
block=floor(length(indRefu)/nodeNum);
rem=mod(length(indRefu),nodeNum);
if node>(nodeNum-rem)
    this.nodeIndRef=indRefu((nodeNum-rem)*block+(node-nodeNum+rem-1)*(block+1)+1:...
        (nodeNum-rem)*block+(node-nodeNum+rem)*(block+1));
else
    this.nodeIndRef=indRefu((node-1)*block+1:node*block);
end
this.basinMask(this.basinMask)=ismember(indRef,this.nodeIndRef);
this.nodeInd=refMask(this.basinMask);
mkdir(this.pathNodeMask);
basinMask=this.basinMask;
save([this.pathNodeMask,'/nodeMask', num2str(node), '_', num2str(nodeNum),'.mat'],'basinMask');
clear basinMask
this.DEM(~this.basinMask)=NaN;
this.FDR(~this.basinMask)=NaN;
this.FAC(~this.basinMask)=NaN;
% this.stream(~this.basinMask)=NaN;
this.lake(~this.basinMask)=NaN;
end