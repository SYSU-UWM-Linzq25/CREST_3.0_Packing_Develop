function changed=hasFileChanged(this)
global fileSto
dateNext=ForcingVariables.addDatenum(this.dateCur,this.timeStep);
switch fileSto
    case 'm' 
        [~,monCur,~,~,~,~]=datevec(this.dateCur);
        [~,monNext,~,~,~,~]=datevec(dateNext);
        changed=monNext~=monCur;
    case 'd'
        [~,~,dayCur,~,~,~]=datevec(this.dateCur);
        [~,~,dayNext,~,~,~]=datevec(dateNext);
        changed=dayCur~=dayNext;
    case 'H'
        [~,~,~,HourCur,~,~]=datevec(this.dateCur);
        [~,~,~,HourNex,~,~]=datevec(dateNext);
        changed=HourCur~=HourNex;
    otherwise
        [~,monCur,~,~,~,~]=datevec(this.dateCur);
        [~,monNext,~,~,~,~]=datevec(dateNext);
        changed=monNext~=monCur;
end
end