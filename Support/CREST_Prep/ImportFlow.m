function [dn,Q]=ImportFlow(siteNumber,splitor,dirQ1,dirQ2,dirFlow,dateFormatQ1,dateFormatQ2,dateStart1,dateStart2,timeStepF)
%% individual settings
fileQ1=[dirQ1,siteNumber,'.csv'];
att=[dirQ2,'*',splitor,siteNumber,'.csv'];
sites=rdir(att);

% fileQ2=[dirQ2,siteNumber,'.csv'];
QOut1=[dirFlow,siteNumber,'_OU_obs.csv'];
QOut2=[dirFlow,siteNumber,'_Shen_obs.csv'];
noData=-9999;
%% common settings
runoffCol=2;
rowStart=2;
dateCol=1;
dateFormatQOut='yyyy-mm-dd:HH:MM';
%% aggregate data of two different sources to hourly
isEmpty=ExtractRunoffUSGS(fileQ1,noData,dateFormatQ1,rowStart,dateCol,runoffCol,dateFormatQOut,dateStart1,timeStepF,...
    'fileFmt','csv','strOut',QOut1,'headFmt','%s %s','recFmt','%s %f');%,'offsetIndex',24);
% read hourly data
if ~isEmpty
    fidQ1=fopen(QOut1,'r');
    % jump the head
    textscan(fidQ1,'%s %s',1,'Delimiter',',');
    dataQ=textscan(fidQ1,'%s %f','Delimiter',',');
    date=char(dataQ{1});
    Q1=dataQ{2};
    clear dataQ
    dn1=datenum(date,dateFormatQOut);
else
    Q1=[];
    dn1=[];
end

if ~isempty(sites) %% compare and merge
    fileQ2=sites.name;
    isEmpty=ExtractRunoffUSGS(fileQ2,noData,dateFormatQ2,rowStart,dateCol,runoffCol,dateFormatQOut,dateStart2,timeStepF,...
        'fileFmt','csv','strOut',QOut2,'offsetIndex',24,'unit','cfs','headFmt','%s %s %s','recFmt','%s %f %s');
    if ~isEmpty
        fidQ2=fopen(QOut2,'r');
        % jump the head
        textscan(fidQ2,'%s %s',1,'Delimiter',',');
        dataQ=textscan(fidQ2,'%s %f','Delimiter',',');
        date=char(dataQ{1});
        Q2=dataQ{2};
        clear dataQ
        dn2=datenum(date,dateFormatQOut);
    else
        Q2=[];
        dn2=[];
    end
else
    Q2=[];
    dn2=[];
end
indMis=~ismember(dn2,dn1);
dn=[dn1;dn2(indMis)];
Q=[Q1;Q2(indMis)];
[dn,idx]=sort(dn);
Q=Q(idx);
clear dn1 dn2 Q1 Q2
%% write the merged file
data=cell(length(Q),2);
date=datestr(dn,dateFormatQOut);
data(:,1)=cellstr(date);
data(:,2)=num2cell(Q);
% data={date,discharge};
clear date discharge
fileObs=[dirFlow,siteNumber,'_obs.csv'];
T = cell2table(data,'VariableNames',{'Date','Discharge'});
writetable(T,fileObs);
delete(QOut1,QOut2)
end