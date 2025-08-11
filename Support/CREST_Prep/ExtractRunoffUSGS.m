function isEmpty=ExtractRunoffUSGS(strUSGS,noData,dateFormatIn,rowStart,dateCol,runoffCol,dateFormatOut,timeStart,timeInt,varargin)%,timeZoneCol,timeZoneOut)
%% extract from USGS streamflow then transfer timezone, average for CREST observation
% written by Shen, Xinyi, June 2014 
% contact: xinyi.shen.uconn.edu
% updated by Shen, Xinyi, April/3, 2015
% updated by Shen, Xinyi, Oct/28, 2015 to accomodate csv input and numeric timezone offset
%% parse input arguments
N=10000;
isEmpty=false;
for i = 1 : 2 : length(varargin)
    switch varargin{i}
        case 'fileFmt'
            fileFmt = varargin{i+1};
        case 'timeZoneCol'
            timeZoneCol = varargin{i+1};
        case 'offsetIndex'
            offsetIndex = varargin{i+1};
        case 'timeZoneOut'
             timeZoneOut= varargin{i+1};
        case 'unit'
             unit=varargin{i+1};
        case 'strOut'
             fileObs=varargin{i+1};
        case 'recFmt'
             recFmt=varargin{i+1};
        case 'headFmt'
             headFmt=varargin{i+1};
        otherwise
    end
end
%% input
% strUSGS: string, file name of the USGS excel
% noData : double, no data value for null or empty values
% dateFormatIn: string,input date format
% rowStart: integer,the starting row of data, (previous rows are considered as description info)
% dateCol: integer,column of dates
% timeZoneCol:integer,column of the timeZone
% runoffCol: integer,column of runoff
% timeStart: datenum, start conversion time in timeZoneOut
% timeInt: datenum, time interval
% dateFormatOut: e.g., 'yyyymmddHH'
% timeZoneOut: target time zone (to adapt the forcing data)
%% Tips
% stage IV daily data is accumulated from 12:00 AM (yesterday) to 12:00 AM (today) UTC
% and you cannot change the time of forcing.
% therefore, it's neccessary to prepare your observation data according to forcing
% you need to set 
    % timeStart=datenum(yyyy,mm,dd-1,12,0,0),
    % timeInt=datenum(0,0,1,0,0,0);
    % timeZoneOut='UTC'

if strcmpi(fileFmt,'csv')
    if ~(exist('headFmt','var') && exist('recFmt','var'))
        error('for csv files, parameter headFmt and recFmt must be provided')
    end
    fid=fopen(strUSGS,'r');
    textscan(fid,headFmt,rowStart-1,'Delimiter',',');
    raw=textscan(fid,recFmt,'Delimiter',',');
    if isempty(raw{2})
        disp('empty flow file');
        isEmpty=true;
        return;
    end
    discharge=raw{2};
    fclose(fid);
else
    [~,~,raw]=xlsread(strUSGS);
    raw=raw(rowStart:end,:);
    discharge=cell2mat(raw(:,runoffCol));
end
if exist('timeZoneCol','var')
    tz_USGS=raw(:,timeZoneCol);
end
if exist('timeZoneOut','var')
    tz_Out=timeZoneOut;
end
% tz_USGS=timeZoneName(tz_USGS_abb);
% tz_Out=timeZoneName(timeZoneOut);

indexInvalid=isnan(discharge) | discharge<-900000;
discharge(indexInvalid)=[];
% discharge(discharge<0)=noData;
if ~strcmpi(fileFmt,'csv')
    if isnumeric(raw{1,dateCol})
        date=cell2mat(raw(:,dateCol));
        date=num2str(date);
    elseif ischar(raw{1,dateCol})
    %     date=char(raw(rowStart:end,dateCol));
        date=raw(:,dateCol);
    end
else
    date=char(raw{dateCol});
end
date(indexInvalid,:)=[];
clear raw

% set the date number start dn to 1 day proir to the start time
dateNumStart=timeStart-1;
%% find the index of the first datetime in the flow file to remove any data prior to this datetime
if isempty(dateFormatIn)
    N1ST=binSearch(date,dateNumStart,@datenum);
else
    N1ST=binSearch(date,dateNumStart,@datenum,dateFormatIn);
end
discharge(1:N1ST-1)=[];
date(1:N1ST-1,:)=[];
dateNum=zeros(length(discharge),1);
%% covert string of date time to date number (block by block if too many)
if ~isempty(dateFormatIn)
    dateLocalStr=date(:,1:length(dateFormatIn));
end
nmin=1;
nmax=min(length(discharge),nmin+N);
while nmin<length(discharge)
    if isempty(dateFormatIn)
        dateNum(nmin:nmax)=datenum(date(nmin:nmax,:));
    else
        dateNum(nmin:nmax)=datenum(dateLocalStr(nmin:nmax,:),dateFormatIn);
    end
    disp(['date conversion ', num2str(nmax),'/' ,num2str(length(discharge))])
    nmin=nmax+1;
    nmax=min(nmax+N,length(discharge));
end
%% adjust timezone difference
if exist('offsetIndex','var')
    offsetHour=str2num(date(:,offsetIndex:offsetIndex+2));
    offsetMin=str2num(date(:,offsetIndex+4:offsetIndex+5));
    dnOffset=datenum(0,0,0,offsetHour,offsetMin,0);
    dateNum=dateNum-dnOffset;
elseif exist('timeZoneOut','var')
    dateNum  = TimezoneConvert( dateNum, tz_USGS, tz_Out );
else
    warning('no timezone info is provided thus no timezone conversion is performed');
end
clear date
%% if neccessary, average the real according to requested time intervals
% convert real date to nTimes of time interval
nDate=(dateNum-timeStart)/timeInt+1;
%% dealing the round error in matlab
int=floor(nDate);
frac=nDate-int;
frac((frac>0.49999)&(frac<0.50001))=0.51;
nDate=int+frac;
%% remove the dates of Q prior to the starting date
nDateInt=round(nDate);
indexInvalid=nDateInt<=0;
nDateInt(indexInvalid)=[];
% nDate(indexInvalid)=[];
discharge(indexInvalid)=[];
%% accumulate stream flow data
% n=ones(length(nDate),1);
% nCount=accumarray(nDateInt,n,[],[],[],true);
% nCount=nonzeros(nCount);
clear raw
discharge=accumarray(nDateInt,discharge,[],@mean,[],true);
% nSum=nonzeros(nSum);
% clear dicharge
% discharge=nSum./nCount;
[nDateInt,~,discharge]=find(discharge);
% nDateInt=unique(nDateInt);
% nDateInt=nDateInt(row);
[dir,name,ext]=fileparts(strUSGS);
ext=strtrim(ext);
date=timeStart+(nDateInt-1)*timeInt;
if exist('fileObs','var')~=1
    fileObs=fullfile(dir,[name,'_obs',ext]);
end
% convert ft^3/s to m^3/s
if exist('unit','var') && strcmpi(unit,'cfs')
    discharge=0.0283168*discharge;
end
discharge(isnan(discharge))=noData;
%% write the accumulated flow data to file
data=cell(length(discharge),2);
date=datestr(date,dateFormatOut);
data(:,1)=cellstr(date);
data(:,2)=num2cell(discharge);
% data={date,discharge};
clear date discharge
if strcmpi(fileFmt,'csv')
    T = cell2table(data,'VariableNames',{'Date','Discharge'});
    writetable(T,fileObs);
else
    xlswrite(fileObs,data);
end

end