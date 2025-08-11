function [shortOverIn,shortUnderIn]=SWPart(this,shortwave)
%% partition the incoming shortwave radiation where there is snow interception
if isempty(shortwave)
    shortwave=[];
end
shortUnderIn=shortwave.*this.short_atten.*(this.hasSnow);
shortOverIn=shortwave-shortUnderIn;
end