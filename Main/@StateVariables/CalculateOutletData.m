function CalculateOutletData(this,timeOfStep,bCalib,masks)
px_ind=sub2ind(size(this.basinMask),this.hydroSites.row,this.hydroSites.col);
for i=1:this.hydroSites.nSites
    if ~bCalib
%         this.px_rain(timeOfStep,i)=mean(this.rain(masks(:,:,i)))/this.timeStepInM;
%         this.px_snow(timeOfStep,i)=mean(this.snow(masks(:,:,i)))/this.timeStepInM;
%         this.px_SWE(timeOfStep,i)=mean(this.SWE(masks(:,:,i)));
%         this.px_intSnow(timeOfStep,i)=mean(this.intSnow(masks(:,:,i)))/this.timeStepInM;
%         this.px_intRain(timeOfStep,i)=mean(this.intRain(masks(:,:,i)))/this.timeStepInM;
%         this.px_rainAct(timeOfStep,i)=mean(this.rainAct(masks(:,:,i)))/this.timeStepInM;
%         this.px_PET(timeOfStep,i)=mean(this.PET(masks(:,:,i)))/this.timeStepInM;
%         this.px_EAct(timeOfStep,i)=mean(this.EAct(masks(:,:,i)))/this.timeStepInM;
%         this.px_W(timeOfStep,i)=mean(this.W(masks(:,:,i)));
    %% I srongly suggest to calculate SM by SM=W0/depth;
%         this.px_SM(timeOfStep,i)=mean(this.W0(masks(:,:,i))./WM(masks(:,:,i)));
        this.px_excS(timeOfStep,i)=mean(this.excS(masks(:,:,i)))/this.timeStepInM;
        this.px_excI(timeOfStep,i)=mean(this.excI(masks(:,:,i)))/this.timeStepInM;
%         this.px_RS(timeOfStep,i)=mean(this.RS(masks(:,:,i)))/this.timeStepInM;
%         this.px_RI(timeOfStep,i)=mean(this.RI(masks(:,:,i)))/this.timeStepInM;
%         this.px_iceSurf(timeOfStep,i)=mean(this.iceSurf(masks(:,:,i)));
%         this.px_icePack(timeOfStep,i)=mean(this.icePack(masks(:,:,i)));
%         this.px_WSurf(timeOfStep,i)=mean(this.WSurf(masks(:,:,i)));
%         this.px_WPack(timeOfStep,i)=mean(this.WPack(masks(:,:,i)));
%         this.px_CCSurf(timeOfStep,i)=mean(this.CCSurf(masks(:,:,i)));
%         this.px_CCPack(timeOfStep,i)=mean(this.CCPack(masks(:,:,i)));
    end
end
this.px_runoff(timeOfStep,:)=this.runoff(px_ind);
end