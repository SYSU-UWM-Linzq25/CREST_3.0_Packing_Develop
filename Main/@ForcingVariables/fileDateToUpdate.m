function dateToRead=fileDateToUpdate(dateCur,dateSto,dateReset,dateInterval)
% read the forcing on the nearest date
[yCur,~,~] = datevec(dateCur);
dateNext=dateSto+dateInterval;
[yNex,~,~]=datevec(dateNext);
if ~isempty(dateReset) && yNex>yCur
    [~,mReset,dReset,HReset,MReset,SReset]=datevec(dateReset);
    dateReset=datenum(yNex,mReset,dReset,HReset,MReset,SReset);
    dateNext=dateReset;
end
dateDiff1=dateCur-dateSto;
dateDiff2=dateNext-dateCur;
if abs(dateDiff1)<abs(dateDiff2)
    dateToRead=dateSto;
else
    dateToRead=dateNext;
end
end