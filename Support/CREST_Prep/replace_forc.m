fileNLDASPrecip='G:\simulation\US_Basins\ConnDOT_I90\prec.201210.mat';
fileCastPrecip='G:\simulation\US_Basins\ConnDOT_I90\New-Haven-Union-Station_Sandy_rainfall_by_WRF.xlsx';
fileNLDASNowcast='G:\simulation\US_Basins\ConnDOT_I90\prec.201210now.mat';
fileNLDASForecast='G:\simulation\US_Basins\ConnDOT_I90\prec.201210fore.mat';
SecADay=86400;
%% read the cast precipitation
[data,txt]=xlsread(fileCastPrecip);
dates=txt(2:end,1);
dates=char(dates);
fmtExt='yyyy-mm-dd HH:MM:SS';
fmtInt='yyyymmddHHMM';
dtStart=datenum(dates(:,1:19),fmtExt);
dtEnd=datenum(dates(:,28:end-4),fmtExt);
timeStep=datenum(0,0,0,1,0,0);
nowcast=mean(data(:,1:5),2);
forecast=mean(data(:,6:end),2);

copyfile(fileNLDASPrecip,fileNLDASNowcast);
copyfile(fileNLDASPrecip,fileNLDASForecast);
SNow=matfile(fileNLDASNowcast,'Writable',true);
SFore=matfile(fileNLDASForecast,'Writable',true);
dtCur=dtStart(1)+datenum(0,0,0,0,30,0);
while dtCur<=dtEnd(end)
    varName=['s',datestr(dtCur,fmtInt)];
    if dtCur<dtStart(2)
        var=S.(varName);
        [rows,cols]=size(var);
    end
    sign1=dtCur-dtStart;
    sign2=dtCur-dtEnd;
    index=find(sign1>=0 & sign2<0);
    nowcastVal=nowcast(index)*ones(rows,cols);
    SNow.(varName)=nowcastVal;
    forecastVal=forecast(index)*ones(rows,cols);
    SFore.(varName)=forecastVal;
    dtCur=(round(dtCur*SecADay)+round(timeStep*SecADay))/SecADay;
    disp(datestr(dtCur));
end