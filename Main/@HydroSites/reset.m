function reset(this)
%% In the beginning of each calibration iteration, this function must be called to reset all accumulative varables to zero
for iVar=1:this.nGObs
    this.nObs{iVar}=zeros(this.nGCells(iVar),1);
    this.sumObs{iVar}=zeros(this.nGCells(iVar),1);
    this.sumObs2{iVar}=zeros(this.nGCells(iVar),1);
    this.GVar{iVar}=zeros(this.nGCells(iVar),1);
    this.sumDiff2{iVar}=zeros(this.nGCells(iVar),1);
    this.sumSim{iVar}=zeros(this.nGCells(iVar),1);
    
    this.dateRefSto(iVar)=ForcingVariables.addDatenum(...
        ForcingVariables.FindFirstForc(this.warmupDate,this.timeStep,this.dateRefInter(iVar),...
            this.datefmtExt{iVar},this.dateRefConv{iVar},this.dirRefExt{iVar},this.fmtExt{iVar}),...
        -this.dateRefInter(iVar));
end
this.started=false;
this.nAgger(:)=0;
this.maskRef=[];
end