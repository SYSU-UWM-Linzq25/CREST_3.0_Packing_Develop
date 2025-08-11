function sNull=ExtractRunoff(fileIn,years,stcds,outputDir,noData)
%% this is a stand alone function that extracts the observed data from the excel file fo CHN hydrology-specified format
%% input 
% years: the data available years
% outputDir: the output directory
% stcds: the ID of hydrologcial sites
%% output 
% the observed variabels will be output to different excel files according
% to its STCD
%% sNull a boolean vector that indicates wether a sites contains measurement
nYear=length(years);
nSites=length(stcds);
outputcolNames={'STCD','DATE','TIME','RUNO'};
gauge=cell(nSites,1);
for i=1:nYear
    year=years(i);
    [~,~,raw]=xlsread(fileIn,num2str(year));
    outputcols=zeros(1,length(outputcolNames));
    for iname=1:length(outputcolNames)
        for c=1:size(raw,2)
            if strcmp(raw{1,c},outputcolNames{iname})==1
                outputcols(iname)=c;
                break;
            end
        end
    end
    dates=datenum(raw(2:end,outputcols(2)))+cell2mat(raw(2:end,outputcols(3)));
    runoff=raw(2:end,outputcols(4));
    sitecode=cell2mat(raw(2:end,outputcols(1)));
    for s=1:nSites
        site=stcds(s);
        index=sitecode==site;
        sdates=dates(index);
        srunoff=runoff(index);
        [usdates,ia,~]=unique(sdates);
        usrunoff=srunoff(ia);
        indexNodata=strcmp(usrunoff,'null')==1;
        usrunoff(indexNodata)={noData};
        usrunoff=cell2mat(usrunoff);
        gauge{s}=[cell2mat(gauge(s));[usdates,usrunoff]];
    end
end
sNull=zeros(nSites,1);
% tdate=datenum(years(1),1,1,clock,0,0):datenum(0,0,1):datenum(years(end),12,31,clock,0,0);
% tdate=tdate';
for s=1:nSites
%     dlmwrite(strcat(outputDir,'\',num2str(stcds(s)),'_obs.csv'),gauge{s});
    discharge=cell2mat(gauge(s));
    if (sum(discharge(:,2)~=-noData)>100)
%         [~,im] = setdiff(tdate,discharge(:,1));
%         indices=ones(length(tdate),1);
%         indices(im)=0;
%         indices=logical(indices);
%         disFinal=zeros(length(tdate),2);
%         disFinal(indices,2)=discharge(:,2);
%         disFinal(~indices,2)=noData;
%         disFinal(:,1)=str2num(datestr(tdate,'yyyymmdd'));
        discharge(:,1)=str2num(datestr(discharge(:,1),'yyyymmddHH'));
%         dlmwrite(strcat(outputDir,'\',num2str(stcds(s)),'_obs.csv'),disFinal,'precision',10);
        dlmwrite(strcat(outputDir,'\',num2str(stcds(s)),'_obs.csv'),discharge,'precision',10);
        data=discharge;
        save(strcat(outputDir,'\',num2str(stcds(s)),'_obs.mat'),'data');
    else
        sNull(s)=1;
    end
end
sNull=logical(sNull);
end