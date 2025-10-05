function CalRoot(this,covers)
% this function calculates the root fraction at each water soil layer for
% different cover types
nTypes=length(covers);
frac=zeros(nTypes,this.nLayers);
nRootLayer=length(covers(1).root_depths);
depWater=cumsum([0;this.depths(:)]);
topWater=depWater(1:end-1);
topWater=topWater(:);
btmWater=depWater(2:end);
btmWater=btmWater(:);
topWater=repmat(topWater,[1,nRootLayer]);
btmWater=repmat(btmWater,[1,nRootLayer]);
for i=1:nTypes
    % calculate the fraction matrix
    depfromTop=cumsum([0,covers(i).root_depths(:)']);
    topRoot=depfromTop(1:end-1);
    btmRoot=depfromTop(2:end);
    topRoot=repmat(topRoot,[this.nLayers,1]);
    btmRoot=repmat(btmRoot,[this.nLayers,1]);
    top=max(topWater,topRoot);
    btm=min(btmWater,btmRoot);
    fracMat=btm-top;
    fracMat(fracMat<0)=0;
    rdMat=repmat(covers(i).root_depths(:)',[this.nLayers,1]);
    fracMat=fracMat./rdMat;
    frac(i,:)=fracMat*covers(i).root_frac(:);
end
frac(:,end)=1-sum(frac(:,1:end-1),2);
this.root=frac(this.index,:);
end