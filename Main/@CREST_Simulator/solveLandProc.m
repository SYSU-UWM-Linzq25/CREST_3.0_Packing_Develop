function [T,nNotConv,it]=solveLandProc(this,T,mask,snowType,iceSurf,icePack,TWThru,rainThru,shortOverIn,shortUnder)
global CP_PM
tolE=1e-2;
maxIt=20;
ub=70;
lb=-70;
switch snowType
    case 'canopy_only'
%         T=nan(this.nCells,2);
         % initial guess of TCanopy
        T11=T(:,[1,2,4]);
        % initial guess of Tfoliage
        T11(~mask,:)=NaN;
        Br=-1/CP_PM*eye(3);
        Br=reshape(Br,[1,3,3]);
        Br=repmat(Br,[this.nCells,1,1]);%1
        [T11,it,nNotConv,mask1]=broyden_v2(T11,Br,@AVG_energy_balances2,3,3,tolE,maxIt,lb,ub,mask,'11',this.canopy,this.soilSurf,this.snowpack,...
                             this.modelPar.optSoilThermal,this.modelPar.evapSurfWater,this.dt,...%mass transformation in the soil layer
                             this.rain,this.Tair,this.airDens,this.pressure,this.eAct,this.VPD,...
                             this.basicVar.DEM(this.basicVar.basinMask),this.LAI,...
                             shortOverIn,shortUnder,this.longwave,...
                             iceSurf,icePack,TWThru,rainThru);
       
        mask=mask&(~mask1);
        if nNotConv>0 % second trail, Tfoliage is free to change
             % first trial, Tfoliage is fixed to zero
            Br=-1/CP_PM*...
                [0,1,0;...
                 0,0,1];
            Br=reshape(Br,[1,2,3]);
            Br=repmat(Br,[this.nCells,1,1]); 
            T12=T(:,[2,4]);
            T12(~mask1,:)=NaN;
            [T12,it2,nNotConv,mask2]=broyden_v2(T12,Br,@AVG_energy_balances2,3,2,tolE,maxIt,lb,ub,mask1,'12',this.canopy,this.soilSurf,this.snowpack,...
                                 this.modelPar.optSoilThermal,this.modelPar.evapSurfWater,this.dt,...%mass transformation in the soil layer
                                 this.rain,this.Tair,this.airDens,this.pressure,this.eAct,this.VPD,...
                                 this.basicVar.DEM(this.basicVar.basinMask),this.LAI,...
                                 shortOverIn,shortUnder,this.longwave,...
                                 iceSurf,icePack,TWThru,rainThru);
            it=it+it2;
            mask1=mask1&(~mask2);
        % converged at the first trial
        end
        if nNotConv>0 % repeat the first strategy with zero initial guess of Tfoliage
            T13=T(:,[1,2,4]);
            T13(mask2,1)=0;
            % initial guess of Tfoliage
            T13(~mask2,:)=NaN;
            Br=-1/CP_PM*eye(3);
            Br=reshape(Br,[1,3,3]);
            Br=repmat(Br,[this.nCells,1,1]); 
            [T13,it,nNotConv,mask3]=broyden_v2(T13,Br,@AVG_energy_balances2,3,3,tolE,maxIt,lb,ub,mask2,'11',this.canopy,this.soilSurf,this.snowpack,...
                             this.modelPar.optSoilThermal,this.modelPar.evapSurfWater,this.dt,...%mass transformation in the soil layer
                             this.rain,this.Tair,this.airDens,this.pressure,this.eAct,this.VPD,...
                             this.basicVar.DEM(this.basicVar.basinMask),this.LAI,...
                             shortOverIn,shortUnder,this.longwave,...
                             iceSurf,icePack,TWThru,rainThru);
             mask2=mask2&(~mask3);
        end
        T(mask,[1,2,4])=T11(mask,:);
        if exist('T12','var')
            T(mask1,1)=0;
            T(mask1,[2,4])=T12(mask1,:);
        end
        if exist('T13','var')
            T(mask2,[1,2,4])=T13(mask2,:);
        end
    case 'pack_only'
        %first trial, temperature of the snowpack and soil surface are free
        %to change
        Br=-1/CP_PM*eye(2);
        Br=reshape(Br,[1,2,2]);
        Br=repmat(Br,[this.nCells,1,1]); 
        T21=T(:,3:4);
        T21(~mask,:)=NaN;
        [T21,it,nNotConv,mask1]=broyden_v2(T21,Br,@AVG_energy_balances2,2,2,tolE,maxIt,lb,ub,mask,'21',this.canopy,this.soilSurf,this.snowpack,...
                                 this.modelPar.optSoilThermal,this.modelPar.evapSurfWater,this.dt,...%mass transformation in the soil layer
                                 this.rain,this.Tair,this.airDens,this.pressure,this.eAct,this.VPD,...
                                 this.basicVar.DEM(this.basicVar.basinMask),this.LAI,...
                                 shortOverIn,shortUnder,this.longwave,...
                                 iceSurf,icePack,TWThru,rainThru);
         mask=mask&(~mask1);
         if nNotConv>0
             % second trial, temperature of the snow pack is fixed to zero
             Br=-1/CP_PM*[0,1];
             Br=reshape(Br,[1,1,2]);
             Br=repmat(Br,[this.nCells,1,1]); 
             T22=T(:,4);
             T22(~mask1)=NaN;
             [T22,it1,nNotConv,mask2]=broyden_v2(T22,Br,@AVG_energy_balances2,2,1,tolE,maxIt,lb,ub,mask1,'22',this.canopy,this.soilSurf,this.snowpack,...
                                 this.modelPar.optSoilThermal,this.modelPar.evapSurfWater,this.dt,...%mass transformation in the soil layer
                                 this.rain,this.Tair,this.airDens,this.pressure,this.eAct,this.VPD,...
                                 this.basicVar.DEM(this.basicVar.basinMask),this.LAI,...
                                 shortOverIn,shortUnder,this.longwave,...
                                 iceSurf,icePack,TWThru,rainThru);
             it=it+it1;
             mask1=mask1&(~mask2);
         end
         if nNotConv>0% use the first solving approach but 0 initial solution
             Br=-1/CP_PM*eye(2);
             Br=reshape(Br,[1,2,2]);
             Br=repmat(Br,[this.nCells,1,1]); 
             T23=T(:,3:4);
             T23(mask2,1)=0;
             T23(~mask2,:)=NaN;
             [T23,it,nNotConv,mask3]=broyden_v2(T23,Br,@AVG_energy_balances2,2,2,tolE,maxIt,lb,ub,mask2,'21',this.canopy,this.soilSurf,this.snowpack,...
                                 this.modelPar.optSoilThermal,this.modelPar.evapSurfWater,this.dt,...%mass transformation in the soil layer
                                 this.rain,this.Tair,this.airDens,this.pressure,this.eAct,this.VPD,...
                                 this.basicVar.DEM(this.basicVar.basinMask),this.LAI,...
                                 shortOverIn,shortUnder,this.longwave,...
                                 iceSurf,icePack,TWThru,rainThru);
             mask2=mask2&(~mask3);
         end
         T(mask,3:4)=T21(mask,:);
         if exist('T22','var')
            T(mask1,3)=0;
            T(mask1,4)=T22(mask1,:);
         end
         if exist('T23','var')
            T(mask2,3:4)=T23(mask2,:);
         end
    case 'both'
        % first trial, all temperatures are free to change
        Br=-1/CP_PM*eye(4);
        Br=reshape(Br,[1,4,4]);
        Br=repmat(Br,[this.nCells,1,1]); 
        T31=T;
        T31(~mask,:)=NaN;%[1,3],
        [T31,it,nNotConv,mask1]=broyden_v2(T31,Br,@AVG_energy_balances2,4,4,tolE,maxIt,lb,ub,mask,'31',this.canopy,this.soilSurf,this.snowpack,...
                                 this.modelPar.optSoilThermal,this.modelPar.evapSurfWater,this.dt,...%mass transformation in the soil layer
                                 this.rain,this.Tair,this.airDens,this.pressure,this.eAct,this.VPD,...
                                 this.basicVar.DEM(this.basicVar.basinMask),this.LAI,...
                                 shortOverIn,shortUnder,this.longwave,...
                                 iceSurf,icePack,TWThru,rainThru);
         mask=mask&(~mask1);
         if nNotConv>0  % trial 2 temperature of snowpack is fixed to 0
             Br=-1/CP_PM*...
                 [1 0 0 0;...
                  0 1 0 0;...
                  0 0 0 1];
             Br=reshape(Br,[1,3,4]);
             Br=repmat(Br,[this.nCells,1,1]);
             T32=T(:,[1,2,4]);
             T32(~mask1,:)=NaN;%1
             [T32,it2,nNotConv,mask2]=broyden_v2(T32,Br,@AVG_energy_balances2,4,3,tolE,maxIt,lb,ub,mask1,'32',this.canopy,this.soilSurf,this.snowpack,...
                                 this.modelPar.optSoilThermal,this.modelPar.evapSurfWater,this.dt,...%mass transformation in the soil layer
                                 this.rain,this.Tair,this.airDens,this.pressure,this.eAct,this.VPD,...
                                 this.basicVar.DEM(this.basicVar.basinMask),this.LAI,...
                                 shortOverIn,shortUnder,this.longwave,...
                                 iceSurf,icePack,TWThru,rainThru);
              mask1=mask1&(~mask2);
              it=it+it2;
         end
         if nNotConv>0 % trial 3 temperature of canopy is fixed to 0
             Br=-1/CP_PM*...
                 [0 1 0 0;...
                  0 0 1 0;...
                  0 0 0 1];
             Br=reshape(Br,[1,3,4]);
             Br=repmat(Br,[this.nCells,1,1]);
             T33=T(:,[2,3,4]);
             T33(~mask2,:)=NaN;%[2]
             [T33,it3,nNotConv,mask3]=broyden_v2(T33,Br,@AVG_energy_balances2,4,3,tolE,maxIt,lb,ub,mask2,'33',this.canopy,this.soilSurf,this.snowpack,...
                                 this.modelPar.optSoilThermal,this.modelPar.evapSurfWater,this.dt,...%mass transformation in the soil layer
                                 this.rain,this.Tair,this.airDens,this.pressure,this.eAct,this.VPD,...
                                 this.basicVar.DEM(this.basicVar.basinMask),this.LAI,...
                                 shortOverIn,shortUnder,this.longwave,...
                                 iceSurf,icePack,TWThru,rainThru);
              mask3=mask3&(~mask2);
              it=it+it3;
         end
         if nNotConv>0 % trial 4 temperature of both snowpack and canopy is fixed to 0
             Br=-1/CP_PM*...
                 [0 1 0 0;...
                  0 0 0 1];
             Br=reshape(Br,[1,2,4]);
             Br=repmat(Br,[this.nCells,1,1]);
             T34=T(:,[2,4]);
             T34(~mask3,:)=NaN;
             [T34,it4,nNotConv,mask4]=broyden_v2(T34,Br,@AVG_energy_balances2,4,2,tolE,maxIt,lb,ub,mask3,'34',this.canopy,this.soilSurf,this.snowpack,...
                                 this.modelPar.optSoilThermal,this.modelPar.evapSurfWater,this.dt,...%mass transformation in the soil layer
                                 this.rain,this.Tair,this.airDens,this.pressure,this.eAct,this.VPD,...
                                 this.basicVar.DEM(this.basicVar.basinMask),this.LAI,...
                                 shortOverIn,shortUnder,this.longwave,...
                                 iceSurf,icePack,TWThru,rainThru);
              it=it+it4;
              mask3=mask3&(~mask4);
         end
         T(mask,:)=T31(mask,:);
         if exist('T32','var')
            T(mask1,[1,2,4])=T32(mask1,:);
            T(mask1,3)=0;
         end
         if exist('T33','var')
            T(mask2,[2,3,4])=T33(mask2,:);
            T(mask2,1)=0;
         end
         if exist('T34','var') && any(mask3)
            T(mask3,[2,4])=T34(mask3,:);
            T(mask3,[1,3])=0;
         end
    case 'no_snow'
        T4=T(:,4);
        T4(~mask)=NaN;
        Br=-1/CP_PM*ones(this.nCells,1);
        [T4,it,nNotConv]=broyden_v2(T4,Br,@AVG_energy_balances2,1,1,tolE,maxIt,lb,ub,mask,'4',this.canopy,this.soilSurf,this.snowpack,...
                                 this.modelPar.optSoilThermal,this.modelPar.evapSurfWater,this.dt,...%mass transformation in the soil layer
                                 this.rain,this.Tair,this.airDens,this.pressure,this.eAct,this.VPD,...
                                 this.basicVar.DEM(this.basicVar.basinMask),this.LAI,...
                                 shortOverIn,shortUnder,this.longwave,...
                                 iceSurf,icePack,TWThru,rainThru);
        T(mask,4)=T4(mask);
end