function infiltrate(this,optInfil,Qd,rainBare,IM)
%% computes the water amount infiltrates to each water layer
%% input
% optInfil:algorithm option
% Qd: direct runoff after interception
%% reference
% SWAT-2009 ch 2.3.2
SWExc=Qd;
switch optInfil
    case 'exponential'
        %% surface
        for iL=1:this.nLayers
            if iL==1% first layer, infiltration obeys the infiltration curve of the Xinanjiang Model
                Wmean=(this.W(:,iL)+this.WOrg(:,iL))/2;
                indexSat=Wmean==this.Wm(:,iL);
                this.Wperc(~indexSat,iL)=SWExc(~indexSat).*(1-exp(-this.Ksat(~indexSat,iL)./(this.Wm(~indexSat,iL)-Wmean(~indexSat))));
                this.Wperc(indexSat,iL)=SWExc(indexSat);
                this.ExcS=Qd-this.Wperc(:,iL);
            else% deeper layers, infiltration obeys the SWAT convention, only occurs if the SW exceeds the Field Holding capacity
                this.Wperc(:,iL)=SWExc.*(1-exp(-this.Ksat(:,iL)./(this.Wm(:,iL)-this.FC(:,iL))));
            end
            if iL<this.nLayers
                SWExc=max(0,this.Wperc(:,iL)+this.W(:,iL+1)-this.FC(:,iL+1));
            end
            if iL>1
                this.W(:,iL)=this.W(:,iL)+this.Wperc(:,iL-1)-this.Wperc(:,iL);
            end
        end
    case 'linear'
        for iL=1:this.nLayers
            Wmean=(this.W(:,iL)+this.WOrg(:,iL))/2;
            this.Wperc(:,iL)=min(SWExc,this.Ksat(:,iL).*Wmean./this.Wm(:,iL));
            if iL==1% first layer, infiltration obeys the infiltration curve of the Xinanjiang Model
                this.ExcS=Qd-this.Wperc(:,iL);
            end
            if iL<this.nLayers
                SWExc=max(0,this.Wperc(:,iL)+this.W(:,iL+1)-this.FC(:,iL+1));
            end
            if iL>1 % soil moisture from layer 2-n will be updated by the difference of infiltration from the two layers
                this.W(:,iL)=this.W(:,iL)+this.Wperc(:,iL-1)-this.Wperc(:,iL);
            end
        end
end
this.ExcS=this.ExcS+rainBare.*IM;
% interflow
this.ExcI=this.Wperc(:,this.nLayers);
end