function destruct(this,dt,dCCSurf,dCCPack,refrozenIcePack,energyPhaseChange,vaporMassEvap,vaporMassSub)
%% Algorithm Description
% this routine finalize the accouting process of the snowpack mass and
    % temperature transferring after energy is balanced
% no cold content is exchanged between the surface and pack layer by
% obeying the following rules
% 1 Both pack CC and surface CC must be consumed up before melting
% 2 Only surface water must be refrozen before surface CC is accumulated 
% 3 All melted water adds to the surface layer first. 
% 4 Pack water never goes up to the surface water except all ice in the pack layer is consumed up
%% outflow (mm)
%% input 
% dCCSurf (W/m^2)
% dCCPack (W/m^2)
% refrozenIcePack(mm)
% energyPhaseChange (W/m^2)
% vaporMassEvap (-mm/s)
% vaporMassSub (-mm/s)
global RHO_W Lf m2mm SMALL MAX_SURFACE_SWQ
%% get the depths before all metaphonism
% status should only be obtained before or after all changes are made
[~,iceSurf,icePack]=this.getIce();
%% I: Apply mass & heat change due to EB to the surface layer
% TSurf is assumed updated
%%% Mass change from EB
this.W=this.W+vaporMassEvap*dt;%WSurf*
iceSurf=iceSurf+vaporMassSub*dt;%iceSurf*
vaporTotal=(vaporMassEvap+vaporMassSub)*dt;
this.swqTotal=this.swqTotal+vaporTotal;%swqTotal*
this.hasSnow=this.swqTotal>0;
%%% +, heat change from EB
% water of all phases must be summed up because liquid water may have be refrozen
swqSurf=iceSurf+this.W+vaporTotal;
this.CCSurf(~this.hasSnow)=0;
% CCSurf*
this.CCSurf(this.hasSnow)=Temp2CC(this.TSurf(this.hasSnow),swqSurf(this.hasSnow),this.CH_negative);
%% II: Apply mass & heat change due to EB to the pack layer
%%% +, heat change from EB
this.CCPack=this.CCPack+dCCPack*dt;%CCPack*
this.CCPack(abs(this.CCPack)<SMALL)=0;
%%% Mass change from EB
this.WPack=this.WPack-refrozenIcePack;%WPack*
icePack=icePack+refrozenIcePack; % icePack*
% swqPack=icePack+this.WPack;
% this.TPack=this.CCPack*m2mm./(swqPack*this.CH_negative);
% this.TPack(swqPack==0)=NaN;
% this.CCSurf=this.CCSurf+dCCSurf*dt;
%% III Apply phase chnage layers by EB to both layers(from pack to surface)
melted=energyPhaseChange<0;
refrozen=energyPhaseChange>0;
%%% melting, rule 1 & 3
dCCPackByMelting=max(this.CCPack(melted),energyPhaseChange(melted)*dt);
% the cold content (virtual ice) of the pack is consumed first if it is melting
this.CCPack(melted)=this.CCPack(melted)-dCCPackByMelting;%% CCPack**
energyPhaseChange(melted)=energyPhaseChange(melted)-dCCPackByMelting/dt;
% melted water is added into the surface layer in the first place
dW=-energyPhaseChange(melted)*dt/(Lf*RHO_W)*m2mm;
this.W(melted)=this.W(melted)+dW;%WSurf**
dIce=min(dW,icePack(melted));
icePack(melted)=icePack(melted)-dIce;%icePack**
dW=dW-dIce;
iceSurf(melted)=iceSurf(melted)-dW;%iceSurf**
% melted ice is subtract from the pack layer to the surface layer
%%% refreezing rule 2 & 4
dW=energyPhaseChange(refrozen)*dt/(Lf*RHO_W)*m2mm;
this.W(refrozen)=this.W(refrozen)-dW;%WSurf***
iceSurf(refrozen)=iceSurf(refrozen)+dW;%iceSurf**
%% IV if the pack ice is consumed up (by melting), all pack water must be added to the surface water
%%% since the melted pack water is assumed at 0 degree, no CC is transfered to the
% surface layer
icePackDepleted=icePack==0;
this.W(icePackDepleted)=this.W(icePackDepleted)+this.WPack(icePackDepleted);%WSurf4*
this.WPack(icePackDepleted)=0;%WPack**
%%% some portion of the water can be refrozen
%CCSurf*,iceSurf***,WSurf5*
[this.CCSurf(icePackDepleted),this.W(icePackDepleted),dIce]=refreeze(this.CCSurf(icePackDepleted),this.W(icePackDepleted));
iceSurf(icePackDepleted)=iceSurf(icePackDepleted)+dIce;
% update the status of the surface layer
% this.TSurf(icePackDepleted)=this.CCSurf(icePackDepleted)*m2mm./(this.swqTotal(icePackDepleted)*this.CH_negative);
% this.TPack(icePackDepleted)=this.TSurf(icePackDepleted);
%% V infiltrate from the surface layer to the pack layer
%%% excessive liquid water is infiltrated from the surface layer to the pack layer
[outflowSurf,this.W]=SnowPack.infiltrate(iceSurf,this.W);%WSurf6
this.WPack=this.WPack+outflowSurf;%WPack3*
%%% from the pack layer to soil
% If there is still negative CCPack, some liquid water can be refrozen.
% This can happen when some part but not all of new ISO rain is partially refrozen
% the rest ISO rain exceeds the holding capacity of the surface layer thus
% is infiltrated to the pack layer. In such situation, there can be remaining
% CC to refreeze the infiltrated water
[this.CCPack,this.WPack,dIce]=refreeze(this.CCPack,this.WPack);%CCPack***,WPack4*
icePack=icePack+dIce;
%% VI pack layer to produce outflow
[this.outflow,this.WPack]=SnowPack.infiltrate(icePack,this.WPack);%WSurf6
this.swqTotal=this.swqTotal-this.outflow;
if any(abs(this.swqTotal-(this.W+this.WPack+iceSurf+icePack))>10*SMALL)
    error('water is not balanced')
end
%% VII redistribute ice, water and cold content
% set the swq zero for small values caused by rounding error

%%% At this point, we finished the internal phase change and outflow
% process of the snow pack with updating CCSurf, CCPack, WSurf, and WPack
% the final step is to redistribute the depth of the surface and pack
% layers with possibly redistribute CC and liquid
dDepth=iceSurf-MAX_SURFACE_SWQ;% positive,swq and CC is transferred from the surface layer to the pack layer, otherwise, pack 2 surf.
% case 1 from surface to pack
surf2pack=dDepth>0;
%%% transfer CC and water
ratio=dDepth(surf2pack)./iceSurf(surf2pack);
dW=this.W(surf2pack).*ratio;
this.WPack(surf2pack)=this.WPack(surf2pack)+dW;
this.W(surf2pack)=this.W(surf2pack)-dW;
dCC=this.CCSurf(surf2pack).*ratio;
this.CCPack(surf2pack)=this.CCPack(surf2pack)+dCC;
this.CCSurf(surf2pack)=this.CCSurf(surf2pack)-dCC;
%%% refreeze some water if possible
[this.CCPack(surf2pack),this.WPack(surf2pack)]=refreeze(this.CCPack(surf2pack),this.WPack(surf2pack));
% case2 from pack to surface
pack2surf=(dDepth<0)&(icePack>0);
dCC=max(this.CCPack(pack2surf),...
        -min(this.W(pack2surf),-dDepth(pack2surf))/m2mm*(Lf*RHO_W));% minimal CC to fill this gap
this.CCPack(pack2surf)=this.CCPack(pack2surf)-dCC;
dDepthFrozen=-dCC/(Lf*RHO_W)*m2mm;
this.W(pack2surf)=this.W(pack2surf)-dDepthFrozen;
% iceSurf(pack2surf)=iceSurf(pack2surf)+dDepthFrozen;
dDepth(pack2surf)=dDepth(pack2surf)+dDepthFrozen;
ratio=min(1,-dDepth(pack2surf)./icePack(pack2surf));
dW=this.WPack(pack2surf).*ratio;
this.W(pack2surf)=this.W(pack2surf)+dW;
this.WPack(pack2surf)=this.WPack(pack2surf)-dW;
dCC=this.CCPack(pack2surf).*ratio;
this.CCSurf(pack2surf)=this.CCSurf(pack2surf)+dCC;
this.CCPack(pack2surf)=this.CCPack(pack2surf)-dCC;
%%% at this point, CC, ice and water have been exchanged between the
%%% surface layer and pack layer. Now update the tempratures
[~,iceSurf,icePack]=this.getIce();
this.removeRoundingError(SMALL);
if any(iceSurf<=0 & this.W>0) || any(icePack<=0 & this.WPack>0)
    error('no ice water in snow pack')
end
this.hasSnow=iceSurf>0;
this.TSurf(~this.hasSnow)=NaN;
this.TSurf(this.hasSnow)=CC2Temp(this.CCSurf(this.hasSnow),iceSurf(this.hasSnow),this.CH_negative);
hasPack=icePack>0;
this.TPack(~hasPack)=NaN;
this.TPack(hasPack)=CC2Temp(this.CCPack(hasPack),icePack(hasPack),this.CH_negative);
end