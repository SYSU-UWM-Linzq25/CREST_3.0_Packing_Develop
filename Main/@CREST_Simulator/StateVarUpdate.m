function StateVarUpdate(this)
%% variables of routing part
% routing related variables
this.stateVar.SS0(this.maskRoute)=this.SS0;
this.stateVar.SI0(this.maskRoute)=this.SI0;
this.stateVar.RS(this.maskRoute)=this.RS;
this.stateVar.RI(this.maskRoute)=this.RI;
% [rows,cols]=size(this.stateVar.basinMask);
% if isempty(this.stateVar.W0)
%     this.stateVar.W0=nan(rows,cols,this.soilSurf.nLayers);
%     this.stateVar.pW0=nan(rows,cols,this.soilSurf.nLayers);
% end
% for iL=1:this.soilSurf.nLayers
%     w0l=nan(rows,cols);
%     w0l(this.stateVar.basinMask)=this.W0(:,iL);
%     this.stateVar.W0(:,:,iL)=w0l;
% % updated on July, 2015 I suggest change
%     w0l(this.stateVar.basinMask)=this.soilSurf.W(:,iL)./this.soilSurf.depths(iL);
% %     this.stateVar.pW0(this.stateVar.basinMask)=this.W0./this.WM*100;
%     this.stateVar.pW0(:,:,iL)=w0l;
% end
end