 function loadSavePts(this,csvPts,load)
if isempty(csvPts) || strcmpi(csvPts,'')
    disp('No saving dates are provided. Skipped');
    return;
end
fid=fopen(csvPts);
% jump over the heads
fgetl(fid);

if ~load
    fmt='%s';
    dates = textscan(fid,fmt,'Delimiter',',');
    this.saveDates=datenum(dates{1},this.timeFormatRoute);
end
if load
    fmt='%s %s %s';
    dates = textscan(fid,fmt,'Delimiter',',');
    this.startDateRoute=datenum(dates{2},this.timeFormatRoute); 
    this.endDateRoute=datenum(dates{3},this.timeFormatRoute);
    if ~isempty(this.out_STCD)
        isOut=strcmpi(this.out_STCD,dates{1});
        this.startDateRoute=this.startDateRoute(isOut);
        this.endDateRoute=this.endDateRoute(isOut);
    end
    this.warmupDateRoute=this.startDateRoute;
    this.nTimeStepsRoute=sum(round((this.endDateRoute-this.warmupDateRoute)/this.timeStepRoute));
end
fclose(fid);
end