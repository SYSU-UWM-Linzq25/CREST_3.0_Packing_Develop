function genHydrograph(this,resPath,dateStart)
%% This function generates the hydrograph after every routing in the forecast mode
% the hydrograph will dispaly -36h ~ +36h 
fmt='%s %f %f %f %f';
fmtHeader='%s %s %s %s %s';
for i=1:this.hydroSites.nSites
    if ischar(this.hydroSites.STCD{i})
        staName=this.hydroSites.STCD{i};
    else
        staName=num2str(this.hydroSites.STCD{i});
    end
    fileNameForecast=[resPath,staName,'.csv'];
    resPathAna=strrep(resPath,'forecast','analysis');
    resPathAna=regexprep(resPathAna, '\d[0-9_]+\d', '');
    resPathAna=strrep(resPathAna,'//','/');
    fileNameAnalysis=[resPathAna,staName,'_summary.csv'];
    figName=strcat(resPath,staName,'.png');
    % read the hydrograph
    fid=fopen(fileNameAnalysis);
%     C=textscan(fid,fmt,1,'Delimiter',',');
%     dt=C{1};
%     dnStartRec=datenum(dt);
%     fclose(fid);
%     rowStart=int32((dateStart-dnStartRec)/datenum(0,0,0,1,0,0))-36;
%     fid=fopen(fileNameAnalysis);
%     textscan(fid,fmt,rowStart-1,'Delimiter',',');
    C=textscan(fid,fmt,'Delimiter',',');
    fclose(fid);
    dn=datenum(C{1},'yyyy/mm/dd:HH');
    ind=find(dn>=dateStart-1,1,'first');
%     ind=find(dn>=dateStart-36/24,1,'first');
    dn=dn(ind:end);
    minDn=min(dn);
    Q=C{end-1};
    Q=Q(ind:end);
    Qmin=min(Q);
    Qmax=max(Q);
    h=figure;
    plot(dn,Q,'k','LineWidth',5);
    hold on
    fid=fopen(fileNameForecast);
    textscan(fid,fmtHeader,1,'Delimiter',',');
    C=textscan(fid,fmt,'Delimiter',',');
    dn=datenum(C{1},'yyyy/mm/dd:HH');
    maxDn=max(dn);
    Q=C{end-1};
    Qmin=min(Qmin,min(Q));
    Qmax=max(Qmax,max(Q));
    plot(dn,Q,'r','LineWidth',2.5);
    % overlay the hydrograph of the past forecast
    datePrev1=dateStart-datenum(0,0,0,12,0,0);
    datePrev2=dateStart-datenum(0,0,1,0,0,0);
%    datePrev3=dateStart-datenum(0,0,1,12,0,0);
    fileNamePrev1=strrep(fileNameForecast,datestr(dateStart,'yyyymmddHHMM'),datestr(datePrev1,'yyyymmddHHMM'));
    fileNamePrev2=strrep(fileNameForecast,datestr(dateStart,'yyyymmddHHMM'),datestr(datePrev2,'yyyymmddHHMM'));
%    fileNamePrev3=strrep(fileNameForecast,datestr(dateStart,'yyyymmddHHMM'),datestr(datePrev3,'yyyymmddHHMM'));
    fid=fopen(fileNamePrev1);
    textscan(fid,fmtHeader,1,'Delimiter',',');
    C=textscan(fid,fmt,'Delimiter',',');
    dn=datenum(C{1},'yyyy/mm/dd:HH');
    Q=C{end-1};
    Qmax=max(Qmax,max(Q));
    Qmin=min(Qmin,min(Q));
    
    plot(dn,Q,'-m','LineWidth',2);
    fid=fopen(fileNamePrev2);
    textscan(fid,fmtHeader,1,'Delimiter',',');
    C=textscan(fid,fmt,'Delimiter',',');
    dn=datenum(C{1},'yyyy/mm/dd:HH');
    Q=C{end-1};
    Qmax=max(Qmax,max(Q));
    Qmin=min(Qmin,min(Q));
    plot(dn,Q,'-c','LineWidth',1);
%     fid=fopen(fileNamePrev3);
%     textscan(fid,fmtHeader,1,'Delimiter',',');
%     C=textscan(fid,fmt,'Delimiter',',');
%     dn=datenum(C{1},'yyyy/mm/dd:HH');
%     Q=C{end-1};
%     plot(dn,Q,'-bo');
    %% plot the current dash line
    dash=Qmin:(Qmax-Qmin)/10:Qmax;
    plot(dateStart*ones(1,length(dash))+0.5/24,dash,'r--');
    plot(dateStart*ones(1,length(dash))-0.5+0.5/24,dash,'m--');
    plot(dateStart*ones(1,length(dash))-1+0.5/24,dash,'c--');
    %% set legend and axes
    xTicks=minDn:datenum(0,0,0,3,0,0):maxDn;
    set(gca,'Xtick',xTicks);
    set(gca,'XtickLabel',datestr(xTicks,'yyyy/mm/dd:HH'));
    ylabel('m^3/s')
    xticklabel_rotate
    lgd=legend('Real-Time',['forecast made at',datestr(dateStart,'yyyy/mm/dd HH:MM') ' (F0)'],...
                       ['forecast made at ' datestr(dateStart-0.5,'yyyy/mm/dd HH:MM') ' (F-12h)'],...
                       ['forecast made at ' datestr(dateStart-1,'yyyy/mm/dd HH:MM') ' (F-24h)'],...
                       'Start of F0','Start of F-12h','Start of F-24h',...
                       'Location','NorthOutside');
    lgd.FontSize=12;
    ylim([Qmin,Qmax]);
    saveas(h,figName);
end
end