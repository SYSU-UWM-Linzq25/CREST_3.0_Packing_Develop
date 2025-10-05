function [evapSoil,evapSurf,PET]=arno_evap(nCells,hasSnow,isOverstory,isBare,feedback,dt,...
                                       netRad,Tair,VPD,elevation,RaC,hasCanopySnow,...
                                       b_infilt,moist_resid,Wm,depth,...
                                       SS0,W)
%% evap (mm)
global m2mm
% two kinds cells that are free of snow pack requires to calculate ET (bare soil, and overstory with intercepted snow)
evapSoil=zeros(nCells,1);
evapSurf=zeros(nCells,1);
PET=zeros(nCells,1);
% hasIntSnow=false(nCells,1);
% hasIntSnow(isOverstory)=hasCanopySnow;
% hasEvap=(isBare|hasIntSnow)&(~hasSnow);    
hasEvap=isBare&(~hasSnow);  
nEvap=sum(hasEvap);
if nEvap==0
    return;
end
%% PET of bare soil
Epot=Penman(elevation(hasEvap),Tair(hasEvap),netRad(hasEvap),VPD(hasEvap),RaC(hasEvap),0,0);
% VIC converts to mm/day?
Epot=Epot*dt;% mm/s to mm/time step
% evaporate the thru fall first
if feedback
    evapSurf(hasEvap)=min(Epot,SS0(hasEvap));
    Epot=Epot-evapSurf(hasEvap);
end
PET(hasEvap)=Epot;
%% maximal infiltration rate, Im in Xinanjiang Model
Wmax=Wm(hasEvap,1);
Wact=W(hasEvap,1);
% depth=this.depths(1);
ratio=1-Wact./Wmax;
ratio(ratio>=1)=1;
ratio(ratio<0)=0;
ratio = ratio.^(1./ (b_infilt(hasEvap) + 1));
% tmpW(this.b_infilt(hasEvap)==-1)=Im;
% tmpW = Im*(1.0 - ratio);
As = 1-ratio.^b_infilt(hasEvap);
s=0;
term=ones(nEvap,1);
for i=0:30
    s=s+b_infilt(hasEvap)./(i+b_infilt(hasEvap)).*term;
    term=term.*ratio;
end
beta_asp = As+(1-As).*(1-ratio).*s;
EVAP=beta_asp.*Epot;
%saturated cells
EVAP(ratio==1)=Epot(ratio==1);

%% Evaporation cannot exceed available soil moisture.
EVAP=min(EVAP,Wact-moist_resid(hasEvap)*depth*m2mm);
EVAP(EVAP<0)=0;
evapSoil(hasEvap)=EVAP;
% evap=evap/dt;
end