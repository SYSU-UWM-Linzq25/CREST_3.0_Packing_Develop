function [correct, begining_date_num, end_date_num]=input_correct(data, obs_per_day, days_per_year, begining_date, end_date, season, resolution)

    correct=1;
    begining_date_num=0;
    end_date_num=0;

    if obs_per_day<1
        disp('Should be at least one observation per day');
        correct=0;
        return
    end

    if (days_per_year<360)|(days_per_year>370)
        disp('Should be 360<=days_per_year<=370');
        correct=0;
        return
    end

    if (days_per_year==365.25)
        begining_date_num=datenum(begining_date);
        end_date_num=datenum(end_date);
    else
        begining_date_num=(begining_date(1)-1)*days_per_year+1;
        end_date_num=end_date(1)*days_per_year;
    end
    
    if end_date_num>0
        if (obs_per_day*(end_date_num-begining_date_num+1)~=length(data))
            disp('There are missing observations or wrong inputs');
            correct=0;
            return
        end
    end
    
    is=ischar(season);
    if (~strcmpi(season,'winter'))&(~strcmpi(season,'spring'))&(~strcmpi(season,'summer'))&(~strcmpi(season,'late summer'))&(~strcmpi(season,'autumn'))&(~strcmpi(season,'all year'))
        disp('Not correctly specified season');
        correct=0;
        return
    end
    
    if (min(obs_per_day./resolution)<1/3)
        disp('Resolution vector incorrect. The lowest resolution that procedure can handle is one observation per 3 days.');
        correct=0;
        return
    end
end