function loadChkPt(this,core,nCores)
% modified by Shen, X in 2019/7/1

% begin updated for analysis by Shen, Xinyi in May 2019

% 2) update for the forecast mode by Shen, X. in Jul. 25, 2019

switch this.globalVar.runStyle
    case 'simu'
        maxRetro=30*365;
    case 'analysis'
        maxRetro=7;
 %% begin 2)
    case 'forecast'
        maxRetro=1.5*datenum(0,0,0,1,0,0);
 %% end 2)
end
% if strcmpi(this.globalVar.runStyle,'simu')
%     maxRetro=30*365;
% elseif strcmpi(this.globalVar.runStyle,'analysis')
%     maxRetro=7;% load from maximumly 7 days ago
% end
% end updated for analysis
dateLastSave=this.forcingVar.dateEnd;
% dateLastSave=datenum(2002,1,2,0,30,0);% test only
if exist('core','var') && exist('nCores','var')
%     fileChkPt=StateVariables.GenerateOutVarNames(this.globalVar.resPathChkPts,...
%         dateLastSave,this.globalVar.timeFormatLS,...
%         this.forcingVar.fmtSubDir,this.forcingVar.pathSplitor,...
%         core,nCores);
      fileChkPt=StateVariables.GenerateOutVarNames(this.globalVar.resPathChkPts,...
        dateLastSave,this.globalVar.timeFormatLS,...
        this.globalVar.timeFormatLS,this.forcingVar.pathSplitor,...
        core,nCores);
else
%     fileChkPt=StateVariables.GenerateOutVarNames(this.globalVar.resPathChkPts,...
%         dateLastSave,this.globalVar.timeFormatLS,...
%         this.forcingVar.fmtSubDir,this.forcingVar.pathSplitor);

     fileChkPt=StateVariables.GenerateOutVarNames(this.globalVar.resPathChkPts,...
        dateLastSave,this.globalVar.timeFormatLS,...
        this.globalVar.timeFormatLS,this.forcingVar.pathSplitor);
end
% %% find the last check point 
% updated. Now CREST looks for the latest checkpoint before the start time
% any existing date time can be a save point
while exist(fileChkPt,'file')~=2 && (this.forcingVar.dateStart-dateLastSave<=maxRetro)% updated by Shen, Xinyi in May 2019
    [year,mon,~,hour,min,sec]=datevec(dateLastSave);
    switch this.globalVar.runStyle
        case 'simu'
            if mon~=1
                mon=mon-1;
            else
                mon=12;
                year=year-1;    
            end
            dateLastSave=datenum(year,mon,15,hour,min,sec);
        case 'analysis'
            dateLastSave=ForcingVariables.addDatenum(dateLastSave,-datenum(0,0,0,12,0,0));
  %% begin 2)
        case 'forecast'
            dateLastSave=ForcingVariables.addDatenum(dateLastSave,-datenum(0,0,0,1,0,0));
  %% end 2)
    end
%     if strcmpi(this.globalVar.runStyle,'simu')
%         if mon~=1
%             mon=mon-1;
%         else
%             mon=12;
%             year=year-1;    
%         end
%         dateLastSave=datenum(year,mon,15,hour,min,sec);
%     elseif strcmpi(this.globalVar.runStyle,'analysis')
%         dateLastSave=ForcingVariables.addDatenum(dateLastSave,-datenum(0,0,0,12,0,0));
%     end
    
%     year=2010;mon=10;%test
    if strcmpi(this.globalVar.runStyle,'forecast') || strcmpi(this.globalVar.runStyle,'analysis')
        fmtChkPt=this.globalVar.timeFormatLS;
    else
        fmtChkPt=this.forcingVar.fmtSubDir;
    end
    
    if exist('core','var') && exist('nCores','var')
        fileChkPt=StateVariables.GenerateOutVarNames(this.globalVar.resPathChkPts,...
            dateLastSave,this.globalVar.timeFormatLS,...
            fmtChkPt,this.forcingVar.pathSplitor,...
            core,nCores);
    else
        fileChkPt=StateVariables.GenerateOutVarNames(this.globalVar.resPathChkPts,...
            dateLastSave,this.globalVar.timeFormatLS,...
            fmtChkPt,this.forcingVar.pathSplitor);
    end
end
if this.forcingVar.dateStart-dateLastSave<=maxRetro
    %% load the last check point point
    this.forcingVar.dateStart=ForcingVariables.addDatenum(dateLastSave,this.forcingVar.timeStep);% updated set the start time to the check point + 1 time step
    disp(['checkPoint loaded on ' datestr(dateLastSave),'.']);
    % this.forcingVar.ioLocker.request();
    % this.forcingVar.ioLocker.checkPermission();
    S=load(fileChkPt);
    % this.forcingVar.ioLocker.release();
    this.soilSurf=S.soilSurf;
    this.snowpack=S.snowpack;
    this.canopy=S.canopy;
    %% set the current date to the check point
    this.forcingVar.iPeriod=0;
    this.forcingVar.reset('simu',this.globalVar.taskType,false,core,nCores);
else
    disp(['no check points found within ',num2str(maxRetro), ' days before the start time. Simulate from the beginning']);
end
end