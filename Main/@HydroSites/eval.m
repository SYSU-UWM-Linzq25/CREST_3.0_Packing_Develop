function eval(this,fileHydro,dateCur,simGVar,mode,iPeriod,isFinal,node,nNodes)
%% this function helps evaluate NSCE of between the observation and simulated variables
% This function must be called once at each time step to accumulate the
% error measure.
% This function deals with multiple variables asynchronically in
%   different grids and paces
% Temporal averaging is performed within this function while the spatial averaging is assumed done by the simulator
if this.warmupDate(iPeriod)>=dateCur
    return;
end
for iVar=1:this.nGObs
   %% add the current time step
    if ~isempty(this.meanSimGVar)
        this.meanSimGVar{iVar}=this.meanSimGVar{iVar}+simGVar{iVar};% accumlate hourly ET to daily
%         this.meanSimGVar{iVar}=(this.meanSimGVar{iVar}*this.nAgger(iVar)+simGVar{iVar})/(this.nAgger(iVar)+1);
    else
        this.meanSimGVar{iVar}=simGVar{iVar};
    end
    this.nAgger(iVar)=this.nAgger(iVar)+1;
    dateToRead=ForcingVariables.fileDateToUpdate(dateCur,this.dateRefSto(iVar),[],this.dateRefInter(iVar));
    if dateToRead~=this.dateRefSto(iVar)% reset the number of aggregating simulation to zero and read the new obs
       %% calculate the nash coefficients
        if ~isempty(this.maskRef)% if not just started
            iGvar=this.GVar{iVar};
            iSumDiff2=this.sumDiff2{iVar};
            iMeanSimGVar=this.meanSimGVar{iVar};
            isumObs=this.sumObs{iVar};
            isumObs2=this.sumObs2{iVar};
            isumSim=this.sumSim{iVar};
            nObsi=this.nObs{iVar};
            iSumDiff2(this.maskRef)=iSumDiff2(this.maskRef)+(iGvar(this.maskRef)-iMeanSimGVar(this.maskRef)).^2;
            isumSim(this.maskRef)=isumSim(this.maskRef)+iMeanSimGVar(this.maskRef);
            this.sumDiff2{iVar}=iSumDiff2;
            this.nAgger(iVar)=1;
            isumObs2(this.maskRef)=isumObs2(this.maskRef)+iGvar(this.maskRef).^2;
            this.sumObs2{iVar}=isumObs2;
            isumObs(this.maskRef)=isumObs(this.maskRef)+iGvar(this.maskRef);
            this.sumObs{iVar}=isumObs;
            this.sumSim{iVar}=isumSim;
           %% save ET graph
            this.saveGraph(fileHydro,dateCur);
           %% reset
            this.meanSimGVar{iVar}=simGVar{iVar};
            nObsi(this.maskRef)=nObsi(this.maskRef)+1;
            this.nObs{iVar}=nObsi;
        end
       %% read new observation data
        refNameInt=ForcingVariables.GenerateIntForcingFileName(this.dirRefInt{iVar},this.datefmtInt{iVar},dateToRead);
        refNameInt=[refNameInt(1:end-3),num2str(node),'_',num2str(nNodes),'.mat'];
        if exist(refNameInt, 'file') == 2 %% processed observation data exist in .mat format
            S=load(refNameInt);
            this.GVar{iVar}=S.ref;
            clear S
        else
            varNameExt=ForcingVariables.GenerateExtForcingFileName(dateToRead,...
                this.dateRefInter(iVar),this.datefmtExt{iVar},this.dateRefConv{iVar},...
                this.dirRefExt{iVar},this.fmtExt{iVar});
            if exist(varNameExt,'file')==2
                ref=ReadRaster(varNameExt);
                ref=ref(this.griddedInd);
                this.GVar{iVar}=ref;
                save(refNameInt,'ref');
            else
                switch mode
                    case 'simu'
                        warning(strcat('missing ', varNameExt, ' data on ', datestr(dateCur)));
                end
            end
        end
        this.maskRef=~isnan(this.GVar{iVar});
        this.dateRefSto(iVar)=dateToRead;
    end
    if isFinal% compute the statistics of the simulation
        this.NSCE{iVar}=1-this.sumDiff2{iVar}./(this.sumObs2{iVar}-this.sumObs{iVar}.^2./this.nObs{iVar});
        this.Bias{iVar}=(this.sumSim{iVar}-this.sumObs{iVar})./this.sumObs{iVar}*100;
        NSCEToSave=zeros(1,2*length(this.NSCE{1})+1);
        NSCEToSave(3:2:end)=this.NSCE{1};
        BiasToSave=zeros(1,2*length(this.Bias{1})+1);
        BiasToSave(3:2:end)=this.Bias{1};
        dlmwrite(fileHydro,NSCEToSave,'delimiter',',','-append');
        dlmwrite(fileHydro,BiasToSave,'delimiter',',','-append');
    end
end
end