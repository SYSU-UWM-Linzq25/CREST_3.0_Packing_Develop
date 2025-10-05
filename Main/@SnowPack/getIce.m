function [ice,iceSurf,icePack]=getIce(this)
global MAX_SURFACE_SWQ
ice  = this.swqTotal - this.WPack - this.W;%
indexSurfaceFull=ice>MAX_SURFACE_SWQ;
iceSurf=zeros(length(ice),1);
iceSurf(ice>MAX_SURFACE_SWQ)=MAX_SURFACE_SWQ;
iceSurf(~indexSurfaceFull)=ice(~indexSurfaceFull);
icePack = ice - iceSurf;
end