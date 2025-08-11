classdef IOLocker<handle
%% this class establish a rank for parallel job to limit the simultaneous I/O operations.
    properties (Access=private)
        strIO='IO_req_';
        IOStatus;
        filePerm;
        fileGranted;
        comFolder;
        comNodeFolder;
        fileIO;
        nodeName;
    end
    properties (GetAccess=public)
        coreID;
        Status;% IO working status of the current core
    end
    methods (Access=public)
        function this=IOLocker(coreID,comFolder)
            this.Status='idle';
            this.coreID=coreID;
            this.comFolder=comFolder;
            this.fileIO=[this.comFolder,this.strIO,num2str(coreID),'.request'];
            this.filePerm=[this.comFolder,'IO_perm_',num2str(coreID),'_*.permission'];
            this.IOStatus=[this.comFolder,'IO_finished_',num2str(coreID),'.status'];
            [~,this.nodeName]=system('hostname');
            % create a folder in communcation folder to exchange info of the local Node
            this.comNodeFolder=[this.comFolder,this.nodeName(1:end-1),this.comFolder(end)];
            if exist(this.comNodeFolder,'dir')~=7
                mkdir(this.comNodeFolder);
            end
        end
        function request(this)
            %create a unique file in the communication file system
            fid=fopen(this.fileIO,'w');
            fclose(fid);
            this.Status='awaiting';
        end
        function checkPermission(this,verbose)
            permitted=false;
            % keep checking whether a permission file exists
            while ~permitted
                pause(0.01);
                granted=dir(this.filePerm);
                if ~isempty(granted)
                    this.fileGranted=granted(1).name;
                    permitted=true;
                    if ~exist('verbose','var') || verbose
                        disp(['Core #',num2str(this.coreID),' gained the I/O permission']);
                    end
                end
            end
            this.Status='running';
        end
        function release(this)
            % remove the permission file
            delete([this.comFolder,this.fileGranted]);
            % after the acquired I/O is completed, change the status of the
            % unique status file in the communication folder
            idSlot=strsplit(this.fileGranted(9:end),'_');
            idSlot=strsplit(idSlot{2},'.');
            idSlot=idSlot{1};
            strSlotToFree=[this.comFolder,'IO_slot_',idSlot];
            movefile([strSlotToFree,'.running'],[strSlotToFree,'.finished']);
            this.Status='finished';
        end
        function finalize(this,msg)
            %% notify the monitor the work has finished
            fid=fopen(this.IOStatus,'w');
            if exist('msg','var')==1 && ~isempty(msg)
               fprintf(fid,msg);
            end
            fclose(fid);
        end
    end
    %% local folder processing
    methods (Access=public)
        cleanLocal(this,coreList,LocalDir,funcHandle,varargin);
        checkLocStartPerm(this);
        [coreList,isMin]=checkThePool(this);
        reportLocalFinish(this);
        dispose(this,coreList,LocalDir);
        exitAtOnce(this);
    end
end