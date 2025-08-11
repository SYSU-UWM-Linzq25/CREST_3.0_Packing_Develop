function cleanLocal(this,coreList,LocalDir,funcHandle,varargin)
%% inputs
% core: the logical core #
% coreList: the list of cores in the given node
% LocalDir: the local directory for all local cores to communicate
% funcHandle: some initial process
%% clean existing folders
list=dir([LocalDir(1:end-1),'*']);
if ~isempty(list)
    disp('cleaning existing local directory')
    try
        rmdir(LocalDir,'s');
        disp(['creating ' LocalDir])
    catch
        disp('no directory requires to remove.')
    end
    mkdir(LocalDir);
end
%% create the folder for the current simulation
% call the external function if some diretory structure needs to be founded
if ~isempty(funcHandle)
    funcHandle(varargin{:});
end
fid=fopen([this.comNodeFolder,'clean.completed'],'w');
fclose(fid);
this.checkLocStartPerm();
%% make sure all cores are notified
for i=1:length(coreList)
    notifiedName=[this.comNodeFolder,num2str(coreList(i)),'.started'];
    while exist(notifiedName,'file')~=2
        pause(2);
    end
end
%% clean all communication files
disp(['all workers in ' this.nodeName ' started']);
delete([this.comNodeFolder,'*.started']);
delete([this.comNodeFolder,'*.completed']);
delete([this.comNodeFolder,'*.pool']);
end