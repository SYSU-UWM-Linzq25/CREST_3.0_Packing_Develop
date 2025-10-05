function CleanSmallWater(this)
%% this function deals with rounding errors
global SMALL
this.intSnow(abs(this.intSnow)<SMALL)=0;
this.W(abs(this.W)<SMALL)=0;
this.WThru(abs(this.WThru)<SMALL)=0;
this.snowThru(abs(this.snowThru)<SMALL)=0;
this.rainDrip(abs(this.rainDrip)<SMALL)=0;
this.snowDrip(abs(this.snowDrip)<SMALL)=0;
end