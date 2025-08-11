function prc=prcLoc(data,res)
prcReg=res:res:100;
valueReg=prctile(data,prcReg);
nPerc=length(valueReg);
nData=length(data);
dataMat=repmat(data,[1,nPerc]);
regMat=repmat(valueReg,[nData,1]);
dist=abs(dataMat-regMat);
[~,index]=min(dist,[],2);
prc=prcReg(index);
end