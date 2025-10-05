function evalLandProcVar(this,mode,bEnd,node,nNodes)
ETCoarse=accumarray(this.basicVar.nodeInd,this.EAct,[],@mean,[],true);
fileName=strcat(this.globalVar.resPathVal,'LandSurfVar_',num2str(node),'.csv');
this.stateVar.hydroSites.eval(fileName,this.forcingVar.dateCur,...
    {full(ETCoarse(this.basicVar.nodeIndRef))},mode,this.forcingVar.iPeriod,bEnd,node,nNodes);
end