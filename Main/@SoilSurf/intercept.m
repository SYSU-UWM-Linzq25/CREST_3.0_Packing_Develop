function intercept(this,feedback,rainfall)
%% calculate the rainfall interception by the vegetation without a canopy layer and the final through fall of cells
%% input
% rainfall : understory rainfall
rainfall(this.hasSnow)=0;
lowVegNoSnow=~(this.isBare|this.isOverstory|this.hasSnow);
this.WVegOrg=this.WVeg;
this.WVeg(~lowVegNoSnow)=0;
this.WVeg(lowVegNoSnow)=min(this.WmVeg(lowVegNoSnow),this.WVeg(lowVegNoSnow)+rainfall(lowVegNoSnow));
this.WThru=this.WVegOrg+rainfall-this.WVeg;
if feedback
    this.WThru=this.WThru+this.SS0;
end
end