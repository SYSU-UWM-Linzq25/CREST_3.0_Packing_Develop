function layeredVar=RedistVar(this,varExt,varExtDepths,basinMask,method,scaledByDepth,scaling)
%% this function redistribute soil saturated moisture to the given layers
% the final Wm is calculated by weighted sum of different fractions
%% input
% SATExt:layered saturation in the layers defined externally(%) of real grids
% SATExtDepths;corresponding exteranl layer depths
% basinMask: the basin mask of the grids
global m2mm
nExtLayers=length(varExtDepths);
depfromTopExt=cumsum([0;varExtDepths]);
topExt=depfromTopExt(1:end-1);
btmExt=depfromTopExt(2:end);
topExt=repmat(topExt(:)',[this.nLayers,1]);
btmExt=repmat(btmExt(:)',[this.nLayers,1]);
depfromTopInt=cumsum([0,this.depths]);
topInt=depfromTopInt(1:end-1);
btmInt=depfromTopInt(2:end);
topInt=repmat(topInt(:),[1,nExtLayers]);
btmInt=repmat(btmInt(:),[1,nExtLayers]);
% top/bottom depth fo the common part
top=max(topExt,topInt);
btm=min(btmExt,btmInt);
frac=max(0,btm-top);
rd=repmat(this.depths(:),[1,nExtLayers]);
frac=frac./rd;
switch method
    case 'weighted_adding' 
        layeredVar=zeros(this.nCells,this.nLayers);
    case 'min'
        layeredVar=inf(this.nCells,this.nLayers);
        frac=frac>0;
end
for le=1:nExtLayers
    varExtLe=varExt(:,:,le);
    for li=1:this.nLayers
        switch method
            case 'weighted_adding'
                layeredVar(:,li)=layeredVar(:,li)+varExtLe(basinMask)*frac(li,le);
            case 'min'
                if frac(li,le)
                    layeredVar(:,li)=min(layeredVar(:,li),varExtLe(basinMask));
                end
        end
    end
end
[rows,cols]=size(basinMask);
[col,row]=meshgrid(1:cols,1:rows);
for li=1:this.nLayers
    layeredVar(:,li)=layeredVar(:,li)*scaling;
    if scaledByDepth
        layeredVar(:,li)=layeredVar(:,li)*this.depths(li)*m2mm;
    end
    varMat=zeros(rows,cols);
    varMat(basinMask)=layeredVar(:,li);
    nanInd=isnan(varMat);
    X=col(~nanInd);
    Y=row(~nanInd);
    misInd=nanInd&basinMask;
    if any(misInd(:))
        clear nanInd
        indVal=sub2ind([rows,cols],Y,X);
        V=varMat(indVal);
        clear indVal
        Xq=col(misInd);
        Yq=row(misInd);
        clear misInd
        Vq=griddata(X,Y,V,Xq,Yq);
    %     Vq=mean(V);
        indInval=sub2ind([rows,cols],Yq,Xq);
        varMat(indInval)=Vq;
        layeredVar(:,li)=varMat(basinMask);
        clear varMat indInval
    end
end

end