function runoffGen(this,rainfall,optInfil,IM)
%% input
% rainfall (mm):total thru rain reaches the soil surface
% IM impermivassive ratio
%% conpmute the infiltration curve
indexOverRain=rainfall>0;
% indexDeficRain=~indexOverRain;
% change from 
% indexSoilUnsat=this.W(:,1)<this.Wm(:,1);% 2.1, 
indexSoilUnsat=this.W(:,1)<this.Wm(:,1);
indexSoilSat=~indexSoilUnsat;
% combine cases
indexUnsatOverRain=indexSoilUnsat & indexOverRain;
indexSatOvrRain=indexSoilSat & indexOverRain;
% effective through fall
% dW=zeros(this.nCells,1);% soil moisture change
Qd=zeros(this.nCells,1);%direct runoff
PSoil=zeros(this.nCells,1);
PSoil(indexOverRain)=rainfall(indexOverRain).*(1.0-IM(indexOverRain));
A=zeros(this.nCells,1);
%% TYPE 2: runoff yield under excess infiltration happens when
      % the soil is unsaturated
        % A,WMM amd PSoilUnSat contain the EXTRACTED overrain and unsaturated elements ONLY
% A is the current y-value of curresponding soil moisture storage(I0)
A(indexUnsatOverRain)=this.WMM(indexUnsatOverRain).*...
    (1.0-(1.0-this.W(indexUnsatOverRain,1)./this.Wm(indexUnsatOverRain,1)).^...
    (1.0./(1.0+this.b_infilt(indexUnsatOverRain))));% A 
%% Qd
%% Type 1
% 1: saturated + overrain
Qd(indexSatOvrRain)=PSoil(indexSatOvrRain);
% 2: unsaturated + overrain(2 cases)
% 2.1: unsaturated+heavy rain
Qd(indexUnsatOverRain)=PSoil(indexUnsatOverRain)-this.Wm(indexUnsatOverRain,1)+this.W(indexUnsatOverRain,1);
indexL=(PSoil+A)<this.WMM;
indexLightRain=indexL & indexUnsatOverRain;% index of light(over) rain and unsaturated cells
indexHeavyRain=(~indexL) & indexUnsatOverRain;
        % soil moisture of heavy rain cells is updated to be saturated.
Qd(indexLightRain)=Qd(indexLightRain)+...
    this.Wm(indexLightRain,1).*...
    (1-(A(indexLightRain)+PSoil(indexLightRain))./this.WMM(indexLightRain)).^...
    (1+this.b_infilt(indexLightRain));
Qd(Qd<0)=0;%? unnecessary
%% update soil moisture
% 1: soil moisture update at rain-deficit cells
% updated in April, 2015
%             dW(indexDeficRain)=(obj.PET(indexDeficRain)-obj.rain(indexDeficRain)).*...
%                 WPrev(indexDeficRain)./obj.WM(indexDeficRain);
%this part has been accounted for in the evap function
% 2: soil mositure update at throughfall cells
  % 2.1 soil moisture of (unsaturated + light) rain cells is updated
this.W(indexLightRain,1)=this.W(indexLightRain,1)+PSoil(indexLightRain)-Qd(indexLightRain);
  % 2.2 TYPE 1: runoff yield under saturated storage happens 
    % when the soil is saturated and there is through fall, soil moisture remains
% this.W(indexSatOvrRain,1)=WPrev(indexSatOvrRain);
    % when the (over) rain is heavy, cells become saturated
this.W(indexHeavyRain,1)=this.Wm(indexHeavyRain,1);
this.infiltrate(optInfil,Qd,rainfall,IM);
end