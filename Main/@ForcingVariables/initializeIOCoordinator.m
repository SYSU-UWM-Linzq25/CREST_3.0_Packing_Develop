function initializeIOCoordinator(this,core)
%% initialize the IOLocker
this.ioLocker=IOLocker(core,this.dirCom);
end