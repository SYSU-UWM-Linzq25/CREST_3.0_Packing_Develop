
dnStart=datenum(1979,1,2,12,0,0);
%dnEnd=datenum(1979,1,3,12,0,0); %just do some test
dnEnd=datenum(2012,12,30,12,0,0);
dt=datenum(0,0,1,0,0,0);
dn=dnStart;
SEC_DAY=86400;
formatout='yyyymmddHH';
while dn<=dnEnd
    % do tasks
    dnStr=datestr(dn,formatout);
    % pathstr='/shared/manoslab/CT_River/forcing/HU_Hourly/';
    pathstr='/shared/manoslab/CT_River/resultNLDAS35/result_daily/';
    file=[pathstr,dnStr(1:8),'/',dnStr,'.mat'];
    m=load(file);
    dirName=[pathstr,dnStr(1:6)];
    if ~isdir(dirName)
        mkdir(dirName);%creat a new file for year and month
    end
    fileNameMon=[pathstr,dnStr(1:6),'/','sta.',dnStr(1:6),'.mat'];
    var_EAct=['EAct_',dnStr];
    cmd=[var_EAct,'=m.EAct;'];
    eval(cmd);
    var_SWE=['SWE_',dnStr];
    cmd=[var_SWE,'=m.SWE;'];
    eval(cmd);
    var_W=['W_',dnStr];
    cmd=[var_W,'=m.W;'];
    eval(cmd);
    var_excI=['excI_',dnStr];
    cmd=[var_excI,'=m.excI;'];
    eval(cmd);
    var_excS=['excS_',dnStr];
    cmd=[var_excS,'=m.excS;'];
    eval(cmd);
    var_rain=['rain_',dnStr];
    cmd=[var_rain,'=m.rain;'];
    eval(cmd);
    var_snow=['snow_',dnStr];
    cmd=[var_snow,'=m.snow;'];
    eval(cmd);

    if exist(fileNameMon, 'file')
    save(fileNameMon,var_EAct,var_SWE,var_W,var_excI,var_excS,var_rain,var_snow,'-append');
    else
    save(fileNameMon,var_EAct,var_SWE,var_W,var_excI,var_excS,var_rain,var_snow,'-v7.3');
    end

    clear m;
    dn=(round(dn*SEC_DAY)+round(dt*SEC_DAY ))/SEC_DAY;
end




