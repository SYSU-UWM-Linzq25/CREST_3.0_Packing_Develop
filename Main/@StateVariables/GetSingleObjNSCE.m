function [NSCE,Bias,CC]=GetSingleObjNSCE(this)
if length(this.hydroSites.indexOutlets)>1
    error('multi-site calibration is not supported in the current version');
elseif isempty(this.hydroSites.indexOutlets)
    warning('no outlet specified')
    NSCE=NaN;
    Bias=NaN;
    CC=NaN;
    return;
end
% global diff_g mRunoff_g
outletRunoff=this.hydroSites.runoff(:,this.hydroSites.indexOutlets);
px_outletRunoff=this.px_runoff(:,this.hydroSites.indexOutlets);
indValid=logical((outletRunoff>0).*(px_outletRunoff>0).*(outletRunoff~=this.hydroSites.noObserv));
sumObs=sum(outletRunoff(indValid));
mRunoff=sumObs/sum(indValid);
diff=px_outletRunoff(indValid)-outletRunoff(indValid);
% diff_g=diff;
% mRunoff_g=mRunoff;
NSCE=sum(diff.^2)./...
    sum((outletRunoff(indValid)-mRunoff).^2);
NSCE=1-NSCE;
if nargout>1
    Bias=(sum(px_outletRunoff(indValid))/sumObs-1)*100;
    CC=corrcoef(px_outletRunoff(indValid),outletRunoff(indValid));
    CC=CC(1,2);
end
end