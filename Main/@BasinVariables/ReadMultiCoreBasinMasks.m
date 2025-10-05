function ReadMultiCoreBasinMasks(this,nCores)
[rows,cols]=size(this.basinMask);
this.multiCoreMasks=zeros(rows,cols);
if nCores>1
    for core=1:nCores
        fileMask=[this.pathNodeMask,'nodeMask', num2str(core), '_', num2str(nCores),'.mat'];
        S=load(fileMask);
        maskCore=S.basinMask;
        this.multiCoreMasks(maskCore)=core;
    end
else
    this.multiCoreMasks=this.basinMask;
end
end
