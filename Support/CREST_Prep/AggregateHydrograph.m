dirEarlier='E:\observation\USGS_historical\';
pathEarlier=[dirEarlier,'\*.xlsx'];
dirLater='E:\observation\CT\';
dirOut='E:\observation\CT_hourly_out\';
allSites=ls(pathEarlier);
noData=-9999;
dateInt=datenum(0,0,0,1,0,0);
w = warning ('off','all');
%% later half
dateFormatInLater='yyyy-mm-ddTHH:MM:SS';
dateFormatOut='yyyymmddHHMM';
rowStartLater=2;dateColLater=1;
dateStartLater=datenum(2007,9,30,21,30,0);
runoffColLater=2;
%% early half
dateFormatInEarlier='yyyymmddHHMMSS';
rowStartEarlier1=3;dateColEarlier=2;
rowStartEarlier2=68;
dateStartEarlier=datenum(1990,10,1,0,30,0);
runoffColEarlier=6;
for i=97:size(allSites,1)
    %% aggregate the later half
    fileName=strtrim(allSites(i,:));
    fileQ1=[dirLater,fileName(1:end-4),'csv'];
    headFmt='%s %s %s';
    recFmt='%s %f %s';
    ExtractRunoffUSGS(fileQ1,noData,dateFormatInLater,rowStartLater,dateColLater,runoffColLater,dateFormatOut,dateStartLater,dateInt,...
    'fileFmt','csv','offsetIndex',24,'headFmt',headFmt,'recFmt',recFmt,'unit','cfs');
    %% aggregate the earlier half
    if ~strcmpi(fileName(1),'0')
        movefile(fileName,['0',fileName]);
    else
        fileQ2=[dirEarlier,fileName];
    end
    ExtractRunoffUSGS(fileQ2,noData,dateFormatInEarlier,...
             rowStartEarlier2,dateColEarlier,runoffColEarlier,...
             dateFormatOut,dateStartEarlier,dateInt,...
        'fileFmt','xlsx','timeZoneCol',3,'timeZoneOut','UTC','unit','cfs');
    %% combine the two time periods
    fileQ1=[fileQ1(1:end-4),'_obs.csv'];
    fileQ2=[fileQ2(1:end-5),'_obs.xlsx'];
    [~,~,raw1] = xlsread(fileQ1);
    [~,~,raw2] = xlsread(fileQ2);
    raw=cell(size(raw2,1)+size(raw1,1)-1,size(raw2,2));
    raw(1:size(raw2,1),:)=raw2;
    raw(size(raw2,1)+1:end,:)=raw1(2:end,:);
    clear raw2 raw1
    T = cell2table(raw,'VariableNames',{'Date','Discharge'});
    fileObs=[dirOut,fileName(1:end-5),'_obs.csv'];
    writetable(T,fileObs);
    delete(fileQ1);
    delete(fileQ2);
    disp(['site ' fileName 'is finished (' num2str(i) '/' num2str(size(allSites,1))])
end
