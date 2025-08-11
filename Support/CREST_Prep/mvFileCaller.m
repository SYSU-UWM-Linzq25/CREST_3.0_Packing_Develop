function mvFileCaller(dirSrc,prefix,nCores0,core,nCores)
SECONDS_PER_DAY=86400;
%% SECTION TITLE
% DESCRIPTIVE TEXT
dtStart=datenum(2002,1,1,0,30,0);
dtEnd=datenum(2012,12,31,23,30,0);
dt=datenum(0,0,0,1,0,0);
% nCores0=210;
nDt=(round(dtEnd*SECONDS_PER_DAY)-round(dtStart*SECONDS_PER_DAY))/round(dt*SECONDS_PER_DAY)+1;
nBlock=ceil(nDt/nCores);
dtStart=(round(dtStart*SECONDS_PER_DAY)+round(SECONDS_PER_DAY*(core-1)*nBlock*dt))/SECONDS_PER_DAY;
if core<nCores
    dtEnd=(round(dtStart*SECONDS_PER_DAY)+round(nBlock*dt*SECONDS_PER_DAY))/SECONDS_PER_DAY;
end
disp(['core#: ', num2str(core),'; dateStart: ',datestr(dtStart),'; dateEnd: ',datestr(dtEnd)]);
% prefix='';
% dirSrc='/scratch/scratch2/CREST/CT_River/result/outvar/';
fmtFile='yyyymmddHHMM';
fmtFolder='yyyymmdd';
mvFiles(dirSrc,prefix,dtStart,dtEnd,dt,fmtFile,fmtFolder,nCores0);
disp('done');
end