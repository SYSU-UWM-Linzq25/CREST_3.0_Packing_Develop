function changed=hasFileChanged(this)
global fileSto
dateNext=ForcingVariables.addDatenum(this.dateCur,this.timeStep);
switch fileSto
    case 'm' 
        [~,monCur,~,~,~,~]=datevec(this.dateCur);
        [~,monNext,~,~,~,~]=datevec(dateNext);
        changed=monNext~=monCur;
    case 'd'
        if strcmpi(this.fmtSubDir,'yyyymmddHH')
            [~,~,~,HourCur,~,~]=datevec(this.dateCur);
            [~,~,~,HourNex,~,~]=datevec(dateNext);
            changed=HourCur~=HourNex;
        else
            [~,~,dayCur,~,~,~]=datevec(this.dateCur);
            [~,~,dayNext,~,~,~]=datevec(dateNext);
            changed=dayCur~=dayNext;
        end
    otherwise
        [~,monCur,~,~,~,~]=datevec(this.dateCur);
        [~,monNext,~,~,~,~]=datevec(dateNext);
        changed=monNext~=monCur;
end
end
