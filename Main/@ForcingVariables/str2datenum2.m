function dm=str2datenum2(str,fmt)
doyInd=[strfind(fmt,'DOY'),strfind(fmt,'doy')];
if isempty(doyInd)
    dm=datenum(str,fmt);
    return;
end
yearInd=[strfind(fmt,'yyyy'),strfind(fmt,'YYYY')];
if ~isempty(yearInd)
    year=str2double(str(yearInd(1):yearInd(1)+3));
end
doyInd=doyInd(1);
try
    doy=str2double(str(doyInd:doyInd+2));
catch
    try
        doy=str2double(str(doyInd:doyInd+1));
    catch
        doy=str2double(str(doyInd));
    end
end
dm=datenum(year,1,1)+doy-1;
end