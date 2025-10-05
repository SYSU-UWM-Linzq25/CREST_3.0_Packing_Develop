function [T1Temp,grndFlux,grndFlux1,netGrndFlux]=nextT1(D1,D2,dp,kappa,Cs,...
     TSurfTemp,T1,T2,dt,optSoilThermal)
%% Algorithm description 
% estimates 
%
% $$T_{1}^+$: the boundary temperature between soil layer 0 and 1
%
switch optSoilThermal
    case 'VIC_406'
        A=Cs(:,2)*dp/dt*(1-exp(-D2/dp));
        B=kappa(:,1)/D1;
        C=kappa(:,2)/D2*(1-exp(-D2/dp)); % CREST
        % C=this.kappa(:,2)/this.D1*exp(-this.D2/this.dp)*(exp(-this.D2/this.dp)-1);   % VIC
        T1Temp=(A.*T1+B.*TSurfTemp+C.*T2)./(A+B+C);
        % G(+) ground flux from the surface soil to the upper layer (-W/m^2)
        grndFlux=kappa(:,1) / D1.* (TSurfTemp-T1Temp);
    case 'VIC_410'
        C1 = Cs(:,2) * dp / D2 * ( 1 - exp(-D2/dp));
        C2 = - (1 - exp(D1/dp)) * exp(-D2/dp);
        C3 = kappa(:,1)/D1 - kappa(:,2)/D1*(1-exp(-D1/dp));
        T1Temp = (kappa(:,1)/(2*D1*D2).*TSurfTemp + C1/dt.*T1+...
                    (2*C2-1+exp(-D1/dp)).*kappa(:,2)/(2*D1*D2).*T2)./...
                (C1/dt + kappa(:,2)/(D1*D2).*C2 + C3/(2*D2));
         % G(+) ground flux from the surface soil to the upper layer (-W/m^2)
         grndFlux=kappa(:,1) / D1.* (TSurfTemp-T1Temp);
         % G1 heat flux  between layer 1 and 0
         grndFlux1=0.5*(grndFlux+kappa(:,2)/D1*(1-exp(-D1/dp)).*(T1Temp-T2));
    case 'Countinuous_Neumann'
        A=kappa(:,1)/D1;
        B=kappa(:,2)/dp;
        T1Temp=(A.*TSurfTemp+B.*T2)./(A+B);
        % only G2 is needed because the energy balance is solved within
        % layer0+layer1
        %G from soil surface to above
        grndFlux=kappa(:,1) / D1.* (TSurfTemp-T1Temp);
        % G2 heat flux  between layer 2 and deeper
        grndFlux1=kappa(:,2)/dp.*(T1Temp-T2)*exp(-D2/dp);
    case 'Independent_Balances'% recommended
        A=Cs(:,2)*dp/dt*(1-exp(-D2/dp));
        B=kappa(:,1)/(2*D1);
        C=-kappa(:,2)/dp*(0.5-exp(-D2/dp));
        T1Temp=(A.*T1+B.*TSurfTemp+C.*T2)./(A+B+C);
        % G(+) ground flux from the surface soil to the upper layer (-W/m^2)
        grndFlux=kappa(:,1) / D1.* (TSurfTemp-T1Temp);
        % G1 heat flux  between layer 1 and 0
        grndFlux1=0.5*(grndFlux+kappa(:,2)/dp.*(T1Temp-T2));
end
% % ground heat flux is downwardlly in layer 0 and is internally
% grndFlux(grndFlux>0)=0;
%% net ground flux due to G(+)-G1(+), used for energy balance
netGrndFlux=grndFlux-grndFlux1;
end