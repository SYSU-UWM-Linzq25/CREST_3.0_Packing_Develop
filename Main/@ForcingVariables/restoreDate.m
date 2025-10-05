function date=restoreDate(date,timeStep,convForc)
global SECONDS_PER_DAY
%% restore the date number from external to model
switch convForc
    case 'Begin'
        date=(round(date*SECONDS_PER_DAY)+round(timeStep*SECONDS_PER_DAY)/2)/SECONDS_PER_DAY;
    case 'End'
        date=(round(date*SECONDS_PER_DAY)-round(timeStep*SECONDS_PER_DAY/2))/SECONDS_PER_DAY;
end
end