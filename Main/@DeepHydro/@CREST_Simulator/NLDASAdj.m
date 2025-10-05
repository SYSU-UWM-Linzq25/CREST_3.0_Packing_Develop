function NLDASAdj(this)
[year,mon,day]=datevec(this.forcingVar.dateCur);
day0=datenum(year,1,1);
doyCur=datenum(year,mon,day)-day0+1;
% warm season
doyWarmStart=datenum(year,12,1)-day0+1;
doyWarmEnd=datenum(year,8,31)-day0+1;
% cold season
% doyColdStart=datenum(year,12,1)-day0+1;
% doyColdEnd=datenum(year,4,30)-day0+1;
% costal season
doyCostalStart=datenum(year,9,1)-day0+1;
doyCostalEnd=datenum(year,11,30)-day0+1;
A=[0.996976019;1.911611;1.2622];
B=[1.249275549;0.79393;1.187738];
C=[0.171190126;0;0.060039];
if doyCur<=doyWarmEnd && doyCur>=doyWarmStart
    index=1;
elseif doyCur<=doyCostalEnd && doyCur>=doyCostalStart
    index=3;
else
    index=2;
end
this.rain=A(index)*this.rain.^B(index)+C(index);
this.snow=A(index)*this.snow.^B(index)+C(index);
end