function mvFiles(prefix,ext,dirSrc,dirDst,dtStart,dtEnd,dt,fmtFile,fmtSubFolder,fileLog)
%% organize forcing files
% example use
% dirSrc='/shared/manoslab/CT_CREST_Simulation/StageIV/'
% prefix='ST4.';
% ext='*.01h.Z';
% fmtFile='yyyymmdd';
% fmtSubFolder='yyyy/DOY';
% dtStart=datenum(2002,1,1);
% dtEnd=datenum(2019,11,12);
% dt=1;
addpath('../CREST_3.0');
SECONDS_PER_DAY=86400;
dtCur=dtStart;
fid=fopen(fileLog,'w');
while dtCur<dtEnd
    folder=[dirDst,ForcingVariables.datenum2str(dtCur,fmtSubFolder,'/')];
    if exist(folder,'dir')~=7
        mkdir(folder);
    end
    strDate=ForcingVariables.datenum2str(dtCur,fmtFile,'/');
    fileName=[prefix,strDate,ext];
    fileSrc=[dirSrc,fileName];
    try
        list=dir([folder,'/',fileName]);
        if length(list)<24
            movefile(fileSrc,[folder,'/'],'f');
        end
    catch
       disp([fileSrc ' do not exist']);
       fprintf(fid,'%s\n',[fileName, ' is missing']);
    end
    disp([datestr(dtCur) ' is finished.'])
    dtCur=(round(dtCur*SECONDS_PER_DAY)+round(dt*SECONDS_PER_DAY))/SECONDS_PER_DAY;
end
fclose(fid);
end