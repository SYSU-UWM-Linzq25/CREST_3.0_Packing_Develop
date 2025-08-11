%% 1) updated by Shen. X in Oct. 21, 2019 to avoid unexpected dead lock
classdef IOMonitor<handle
    properties (Access=private)
        jobStatus=false;
        comFolder;
        fileStatusRunning;
        fileStatusFinished;
        nCores;
        maxIO;
    end
    methods(Access=public)
        function this=IOMonitor(maxIO,comFolder,nCores)
            this.maxIO=maxIO;
            this.comFolder=comFolder;
            this.nCores=nCores;
            %create a finsihed status file to indicate idle
            this.fileStatusRunning=cell(this.maxIO,1);
            this.fileStatusFinished=cell(this.maxIO,1);
            for i=1:this.maxIO
                this.fileStatusRunning{i}=[this.comFolder,'IO_slot_',num2str(i),'.running'];
                this.fileStatusFinished{i}=[this.comFolder,'IO_slot_',num2str(i),'.finished'];
                fid=fopen(this.fileStatusFinished{i},'w');
                fclose(fid);
            end
        end
        function monitorMatlab(this)
            for core=1:this.nCores
                threadStatus=[this.comFolder,'IO_mat_thread_',num2str(core),'.started'];
                while exist(threadStatus,'file')~=2
                    pause(0.1);
%                     disp([threadStatus,' is missing']);
                end
                disp(['core: ' num2str(core) ' started']);
            end
            disp('All matlab sessions started. The monitor starts to grant I/O permissions');
            delete([this.comFolder,'*.started']);
        end
        function monitor(this)
            % check the status of ongoing I/O
            while true
%% 1)                
%                 freeSlots=[];
                freeSlots=this.checkStatus();
%% end 1)
                if this.terminateCond()
                    break;
                end
%% 1)
                if ~isempty(freeSlots)
                    this.grantPermission(freeSlots);
                else
                    pause(0.01);
                end
%                 while isempty(freeSlots)
%                     pause(0.01);
%                     freeSlots=checkStatus(this);
%                 end
                % grant a new permission
%                 this.grantPermission(freeSlots);
%% end 1)
            end
            this.dispose();
        end
    end
    methods(Access=private)
        function freeSlots=checkStatus(this)
            IOCompleted=dir([this.comFolder,'IO_slot_*.finished']);
            if ~isempty(IOCompleted)
                strFree=char({IOCompleted.name});
                strFree=strFree(:,9:end-9);
                freeSlots=str2num(strFree);
            else
                freeSlots=[];
            end
        end
        function granted=grantPermission(this,freeSlots)
            files=dir([this.comFolder,'*.request']);
            if ~isempty(files)
                % find the earliest request to grant in the waiting pool(does not have to be
                % the real earliest.
                dates=datenum({files.date});
                for i=1:length(freeSlots)
                    if isempty(dates)
                        break;
                    end
                    [~,idx]=min(dates);
                    % remove the request file since the permission is granted
                    delete([this.comFolder,files(idx).name]);
                    coreID=files(idx).name(8:end-8);
                    files(idx)=[];
                    dates(idx)=[];
                    filePerm=[this.comFolder,'IO_perm_',num2str(coreID),'_',num2str(freeSlots(i)),'.permission'];
                    % change the status of the used slot
                    % this must be done pior to create the permission file
                    % to prevent the worker tries to modify to running
                    % status before it exists
                    movefile(this.fileStatusFinished{freeSlots(i)},this.fileStatusRunning{freeSlots(i)});
                    % create a new permission file
                    fid=fopen(filePerm,'w');
                    fclose(fid);
                end
                granted=true;
            else
                granted=false;
            end
        end
        function finished=terminateCond(this)
            files=dir([this.comFolder,'*.status']);
            bErr=false;
            if length(files)==this.nCores
                for i=1:length(files)
                    fid=fopen([this.comFolder,files(i).name]);
                    content=fgetl(fid);
                    if strcmpi(content, 'Aborted')
                        bErr=true;
                        fclose(fid);
                        break;
                    end
                    fclose(fid);
                end
                if bErr
                    disp('At least one core is aborted');
                else
                    disp('no more I/O operations are needed. IO monitor exists');
                end
                finished=true;
            else
                finished=false;
            end
        end
        function dispose(this)
            rmdir(this.comFolder,'s');
        end
    end
end