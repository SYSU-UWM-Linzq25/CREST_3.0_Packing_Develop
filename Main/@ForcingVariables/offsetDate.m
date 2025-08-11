function date=offsetDate(date,timeStep,convForc)
global SECONDS_PER_DAY
%% offset the date number by external convention
switch convForc
    case 'Begin'
        date=(round(date*SECONDS_PER_DAY)-round(timeStep*SECONDS_PER_DAY)/2)/SECONDS_PER_DAY;
    case 'End'
        date=(round(date*SECONDS_PER_DAY)+round(timeStep*SECONDS_PER_DAY/2))/SECONDS_PER_DAY;
end
end