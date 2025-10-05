function filledMat=FillMissing(orgMat,mask,LLim,ULim)
%% this function fills missing data denoted by NaN values in any basin cells denoted by mask
% orgMat: the orignal matrix with NaN values in basin mask
% mask: a logical matrix representing the basin area
% LLim,ULim: lower and upper limit of the variable
%% step 1 fill missing values by interpolation
[rows,cols]=size(orgMat);
[col,row]=meshgrid(1:cols,1:rows);
varMat=zeros(rows,cols);
varMat(mask)=orgMat(mask);
nanInd=isnan(varMat)| (varMat<LLim) | (varMat>ULim);
X=col(~nanInd);
Y=row(~nanInd);
misInd=nanInd&mask;
filledMat=orgMat;
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
    filledMat(mask)=varMat(mask);
    clear varMat indInval
end
filledMat(filledMat<LLim)=LLim;
filledMat(filledMat>ULim)=ULim;
% %% step 2 for area where the nearest
% nanInd=isnan(filledMat);
% misInd=nanInd&mask;
% if any(misInd(:))
%     rowMis=row(misInd);
%     colMis=col(misInd);
%     rw=-thw:thw;
%     cw=-thw:thw;
%     [cw,rw]=meshgrid(cw,rw);
%     cw=cw(:);
%     rw=rw(:);
%     [rw,rowMeshed]=meshgrid(rw,rowMis);
%     [cw,colMeshed]=meshgrid(rcw,colMis);
%     dist=sqrt(rw^2+cw^2);
%     r=rowMeshed+rw;
%     c=colMeshed+cw;
%     r=max(r,1);
%     r=min(r,rows);
%     c=max(c,1);
%     c=min(c,cols);
%     ind=sub2ind([rows,cols],r,c);
%     val=filledMat(ind);
%     dist(isnan(val))=Inf;
%     [~,loc]=min(dist,2);
%     indMis=sub2ind([rows,cols],rowMis,colMis);
%     indVal=sub2ind([length(rowMis),size(dist,2)],1:length(rowMis),loc);
%     filledMat(indMis)=filledMat(indVal);
% end
end