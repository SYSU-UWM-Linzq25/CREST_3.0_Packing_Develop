function genBasinInd(this,basinMask)
%% global 1-d index of all local basin cells
indNonZero=find(basinMask);
maskStart=[true;indNonZero(2:end)-indNonZero(1:end-1)~=1];
maskEnd=[maskStart(2:end);true];
this.basinInd=zeros(sum(maskEnd),2);
this.basinInd(:,1)=indNonZero(maskStart);
this.basinInd(:,2)=indNonZero(maskEnd);
this.localInd=zeros(size(this.basinInd));
this.localInd(:,2)=find(maskEnd);
lens=this.basinInd(:,2)-this.basinInd(:,1)+1;
this.localInd(:,1)=this.localInd(:,2)-lens+1;
end