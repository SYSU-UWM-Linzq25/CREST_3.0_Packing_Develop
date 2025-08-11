function [iceSurf,icePack]=compact(this,dt,date,lat,rainfall,snowfall,TSnow)
%% compaction process of snow pack due to rainfall and snowfall
global MAX_SURFACE_SWQ m2mm RHO_W Lf MIN_SWQ_EB_THRES
%% total ice
[~,iceSurf,icePack]=getIce(this);
% %% Calculate cold contents 
% snowFallCC=MixedHeatChange(TSnow,0,snowfall,this.CH_positive,this.CH_negative);
snowFallCC=this.CH_negative*snowfall/m2mm.*TSnow;
%% distribute fresh snow
isSurfaceFull=snowfall>(MAX_SURFACE_SWQ-iceSurf);
% the surface layer reaches the maximum SWQ
dPackSwq=zeros(this.nCells,1);
dPackCC=zeros(this.nCells,1);
dPackSwq(isSurfaceFull) = iceSurf(isSurfaceFull) + snowfall(isSurfaceFull) - MAX_SURFACE_SWQ;
isSurfaceFresh=dPackSwq>iceSurf;
dPackCC(isSurfaceFresh)=this.CCSurf(isSurfaceFresh)+(snowfall(isSurfaceFresh)-MAX_SURFACE_SWQ)./snowfall(isSurfaceFresh).*snowFallCC(isSurfaceFresh);
isFullnFresh=(~isSurfaceFresh) & isSurfaceFull;
dPackCC(isFullnFresh)=dPackSwq(isFullnFresh)./iceSurf(isFullnFresh).*this.CCSurf(isFullnFresh);
this.CCPack(isSurfaceFull)=this.CCPack(isSurfaceFull)+dPackCC(isSurfaceFull);
this.CCSurf(isSurfaceFull)=this.CCSurf(isSurfaceFull)+snowFallCC(isSurfaceFull)-dPackCC(isSurfaceFull);
iceSurf(isSurfaceFull)=MAX_SURFACE_SWQ;
icePack(isSurfaceFull)=icePack(isSurfaceFull)+dPackSwq(isSurfaceFull);
% the surface layer is not full, no pack layer exists
iceSurf(~isSurfaceFull)=iceSurf(~isSurfaceFull)+snowfall(~isSurfaceFull);
this.CCSurf(~isSurfaceFull)=this.CCSurf(~isSurfaceFull)+snowFallCC(~isSurfaceFull);

%% update the temperature of both layers
this.hasSnow=iceSurf>0;
%% water phase of the pack layer must be changed here because no balance of the pack layer is calculated
hasPack=icePack>0;
refreezeCap= this.WPack(hasPack)/m2mm*Lf*RHO_W;
dCCPackRefrozen=max(this.CCPack(hasPack),-refreezeCap);
this.CCPack(hasPack)=this.CCPack(hasPack)-dCCPackRefrozen;
% some liquid water are refrozen
dSwqPack=-dCCPackRefrozen/(Lf*RHO_W)*m2mm;
this.WPack(hasPack)=this.WPack(hasPack)-dSwqPack;
icePack(hasPack)=icePack(hasPack)+dSwqPack;
%% compute the temperature of the snowpack after compaction
this.TPack(hasPack)=this.CCPack(hasPack)./(this.CH_negative*icePack(hasPack))*m2mm;
this.TPack(icePack<=0)=NaN;
%% add rainfall to the surface layer
this.W(this.hasSnow) = this.W(this.hasSnow)+rainfall(this.hasSnow);
this.swqTotal=icePack+iceSurf+this.W+this.WPack;
this.removeRoundingError(MIN_SWQ_EB_THRES);
% this.removeRoundingError(SMALL);
%% update the temperature of the surface layer
this.TSurf(this.hasSnow)=this.CCSurf(this.hasSnow)./(this.CH_negative*iceSurf(this.hasSnow))*m2mm;
% this.TSurf(this.hasSnow)=this.CCSurf(this.hasSnow)./(this.CH_negative*(iceSurf(this.hasSnow)+this.W(this.hasSnow)))*m2mm;
this.TSurf(~this.hasSnow)=NaN;%nonsense
%% update snow pack status
this.updateAge(snowfall);
this.updateAlbedo(dt,snowfall);
this.updateMeltingStatus(date,lat,snowfall);
end