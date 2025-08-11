function USGSDownloader(siteNumber,dirOut)
%% created in 2019
dtStart=datenum(2007,10,1);
dtEnd=today;
dtCur=dtStart;
codeDischarge='00060';
url='http://waterservices.usgs.gov/nwis/iv/?format=waterml,2.0';
dt=365;
fileOutRoot=[dirOut,siteNumber,'_'];
fileOut=[dirOut,siteNumber,'.csv'];
firstTable=true;
while dtCur<dtEnd
    strStart=datestr(dtCur,'yyyy-mm-dd');
    strEnd=datestr(dtCur+365,'yyyy-mm-dd');
    disp(['retrieving ',strStart,' to ',strEnd,'...']);
    urlSite=[url,'&sites=',siteNumber,'&startDT=',strStart,'&endDT=',strEnd,'&parameterCd=',codeDischarge];
    options = weboptions;
    options.Timeout = 30;
    content=webread(urlSite,options);
    xmlFile=[dirOut,'temp.xml'];
    fidXml=fopen([dirOut,'temp.xml'],'w');
    fprintf(fidXml,content);
    fclose(fidXml);
    S= xml2struct(xmlFile);
    if isfield(S,'wml2_colon_Collection')
        data=S.wml2_colon_Collection.wml2_colon_observationMember.om_colon_OM_Observation.om_colon_result.wml2_colon_MeasurementTimeseries.wml2_colon_point;
    else
        disp('empty record, move the start time to one year later');
        dtCur=dtCur+dt;
        continue;
    end
    T=cell2table(data');
    clear data S
    S=table2struct(T);
    Var1=[S.Var1];clear S
    MTVP=[Var1.wml2_colon_MeasurementTVP];
    time=[MTVP.wml2_colon_time];
%     time=char({time.Text});
    value=[MTVP.wml2_colon_value];clear MTVP
%     Q=cellfun(@str2num,{value.Text})';
    Tw=cell2table([{time.Text}',{value.Text}'],'VariableNames',{'Date','Discharge_cfs'});
    fileOuti=[fileOutRoot,strStart,'.csv'];
    dtCur=dtCur+dt;
    writetable(Tw,fileOuti,'WriteVariableNames',firstTable);
    if firstTable
        firstTable=false;
    end
end
%% merge all tables
if ispc
    cmd=['! copy ', fileOutRoot,'*.csv ', fileOut];

elseif isunix
    cmd=['! cat ',fileOutRoot,'*.csv > ', fileOut];
end
eval(cmd);
delete([fileOutRoot,'*.csv']);
delete([dirOut,'temp.xml']);
end